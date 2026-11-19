import java.io.File;
import java.lang.management.*;
import java.util.*;
import com.stephengware.java.glaive.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.ss.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Separately invoked diagnostics; never replaces the frozen runtime. */
public class GlaivePhaseProbe {
    static final long START = System.nanoTime();
    static volatile String phase = "startup";
    static String quote(String s) {
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r") + "\"";
    }
    static void emit(String kind, String data) {
        long gc = 0;
        for (GarbageCollectorMXBean b : ManagementFactory.getGarbageCollectorMXBeans())
            gc += Math.max(0, b.getCollectionTime());
        System.out.println("{\"kind\":" + quote(kind) + ",\"phase\":" + quote(phase) +
            ",\"seconds\":" + ((System.nanoTime()-START)/1e9) +
            ",\"heap_bytes\":" + ManagementFactory.getMemoryMXBean().getHeapMemoryUsage().getUsed() +
            ",\"gc_ms\":" + gc + (data.length() == 0 ? "" : "," + data) + "}");
        System.out.flush();
    }
    static void begin(String p) { phase = p; emit("begin", ""); }
    static void sampler(final Thread main) {
        Thread t = new Thread(() -> {
            while (true) {
                try { Thread.sleep(2000); } catch (InterruptedException e) { return; }
                StringBuilder trace = new StringBuilder();
                for (StackTraceElement frame : main.getStackTrace()) trace.append(frame.toString()).append('\n');
                emit("sample", "\"main_cpu_seconds\":" + ManagementFactory.getThreadMXBean().getThreadCpuTime(main.getId())/1e9 +
                     ",\"stack\":" + quote(trace.toString()));
            }
        });
        t.setDaemon(true); t.start();
    }
    static class TimedGrounder implements ObjectGrounder<Operator, IntentionalProblem> {
        final ObjectGrounder<Operator, IntentionalProblem> delegate;
        TimedGrounder(ObjectGrounder<Operator, IntentionalProblem> delegate) { this.delegate = delegate; }
        public Set<Object> ground(Operator op, Grounder<IntentionalProblem> grounder) {
            phase = "ground_operator:" + op.name; emit("begin", "\"arity\":" + op.parameters.length);
            Set<Object> result = delegate.ground(op, grounder);
            emit("end", "\"steps\":" + result.size());
            phase = "state_space_finalize";
            return result;
        }
    }
    static AxiomTree directAxioms(IntentionalProblem problem) {
        Grounder<IntentionalProblem> g = new Grounder<>(problem);
        LinkedHashSet<Axiom> axioms = new LinkedHashSet<>();
        for (AxiomTemplate t : problem.domain.axioms)
            for (Axiom a : g.ground(t, Axiom.class))
                if (a.context != Expression.FALSE) axioms.add(a);
        return new AxiomTree(new ImmutableSet<Axiom>(axioms, Axiom.class));
    }
    public static void main(String[] argv) throws Exception {
        sampler(Thread.currentThread());
        String mode = argv[0];
        Glaive planner = new Glaive(); ArgumentMap a = planner.makeArguments();
        a.set(Glaive.DOMAIN, argv[1]); a.set(Glaive.PROBLEM, argv[2]);
        begin("parse_domain"); IntentionalDomain d = a.get(Glaive.DOMAIN); emit("end", "\"operators\":" + d.operators.length + ",\"axioms\":" + d.axioms.length);
        begin("parse_problem"); IntentionalProblem p = a.get(Glaive.PROBLEM); emit("end", "\"objects\":" + p.universe.objects.length);
        if (mode.equals("parse")) return;
        if (mode.startsWith("replay")) {
            begin("read_plan"); Plan plan = a.get(Glaive.IO_MANAGER).read(new File(argv[3]), Plan.class); emit("end", "");
            begin("replay_axiom_tree");
            AxiomTree tree = mode.equals("replay-direct") ? directAxioms(p) : a.get(Glaive.AXIOM_TREE);
            emit("end", "");
            begin("replay_steps"); GlaivePlan replay = new GlaivePlan("profile-replay", p, tree);
            int count = 0;
            for (Step step : plan.steps()) {
                if (!(step instanceof IntentionalStep) || !replay.getCurrentState().isTrue(step.precondition))
                    throw new IllegalArgumentException("Inapplicable or nonintentional step " + count);
                replay.addStep((IntentionalStep) step); count++;
            }
            boolean goal = replay.getCurrentState().isTrue(p.getGoal());
            emit("result", "\"goal\":" + goal + ",\"steps\":" + count + ",\"unexplained\":" + replay.countUnexplainedSteps() + ",\"orphans\":" + replay.countOrphans());
            if (!goal) System.exit(2);
        } else {
            begin("state_space"); Grounder<IntentionalProblem> g = new Grounder<>(p);
            if (mode.contains("guarded")) g.setObjectGrounder(Operator.class, new GlaiveStaticGuardGrounder(p));
            g.setObjectGrounder(Operator.class, new TimedGrounder(g.getObjectGrounder(Operator.class)));
            IntentionalStateSpace space = new IntentionalStateSpace(g);
            a.set(Glaive.STATE_SPACE, space); phase = "state_space";
            emit("end", "\"steps\":" + space.steps.length + ",\"literals\":" + space.literals.length + ",\"axioms\":" + space.axioms.length);
            if (mode.equals("ground")) return;
            if (mode.contains("axioms")) {
                begin("axiom_static_guards");
                ImmutableSet<Axiom> filtered = GlaiveStaticAxiomFilter.filter(p, space.axioms);
                space = new IntentionalStateSpace(p, space.literals, space.steps, filtered);
                a.set(Glaive.STATE_SPACE, space);
                emit("end", "\"axioms\":" + filtered.length);
            }
            begin("axiom_tree"); a.get(Glaive.AXIOM_TREE); emit("end", "");
            begin("search_setup"); Search search = planner.search(a); emit("end", "");
            a.set(Glaive.TIME_LIMIT, 60000);
            begin("search"); Result result = search.getNextPlan(a);
            emit("result", "\"solved\":" + result.getSuccess() + ",\"visited\":" + result.getVisited() + ",\"generated\":" + result.getGenerated());
            if (result.getSuccess()) a.get(Glaive.IO_MANAGER).write(result.getPlan(), new File(argv[3]));
        }
    }
}
