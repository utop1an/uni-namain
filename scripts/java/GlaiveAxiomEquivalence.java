import java.io.File;
import java.util.*;
import com.stephengware.java.glaive.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Compare unchanged grounded axiom contexts with the static simplification.
 * Linear scanning is a separate diagnostic interpreter, avoiding tree creation.
 */
public class GlaiveAxiomEquivalence {
    static class LinearTree extends AxiomTree {
        final List<Axiom> rules = new ArrayList<>();
        LinearTree(ImmutableSet<Axiom> axioms) {
            super(new ImmutableSet<Axiom>(new Axiom[0]));
            for (Axiom ax : axioms) {
                if (ax.getPreconditionClauses().size() <= 1) rules.add(ax);
                else for (Clause c : ax.getPreconditionClauses()) rules.add(new Axiom(c.expression, ax.implies));
            }
        }
        @Override public Iterator<Axiom> getApplicableAxioms(State state) {
            List<Axiom> result = new ArrayList<>();
            for (Axiom ax : rules) if (state.isTrue(ax.context)) result.add(ax);
            return result.iterator();
        }
    }
    static Set<String> literals(State s) {
        Set<String> result = new TreeSet<>(); for (Literal l : s) result.add(l.toString()); return result;
    }
    static void require(boolean b, String message) { if (!b) throw new AssertionError(message); }
    public static void main(String[] argv) throws Exception {
        ArgumentMap a = new Glaive().makeArguments(); a.set(Glaive.DOMAIN, argv[0]); a.set(Glaive.PROBLEM, argv[1]);
        IntentionalProblem p = a.get(Glaive.PROBLEM);
        Grounder<IntentionalProblem> g = new Grounder<>(p); Set<Axiom> set = new LinkedHashSet<>();
        for (AxiomTemplate t : p.domain.axioms) set.addAll(g.ground(t, Axiom.class));
        ImmutableSet<Axiom> original = new ImmutableSet<>(set, Axiom.class);
        ImmutableSet<Axiom> simplified = GlaiveStaticAxiomFilter.filter(p, original);
        LinearTree reference = new LinearTree(original);
        AxiomTree optimized = new AxiomTree(simplified);
        int checks = 0;
        if (argv[2].equals("fixture")) {
            // Enumerate all flag/mutable-membership valuations for a and b.
            Constant ca = null, cb = null;
            for (Constant c : p.universe.objects) { if (c.name.equals("a")) ca=c; if (c.name.equals("b")) cb=c; }
            for (int mask=0;mask<16;mask++) {
                List<Expression> facts = new ArrayList<>(); facts.add(p.getInitialState());
                if ((mask&1)!=0) facts.add(new Predication("flag",ca));
                if ((mask&2)!=0) facts.add(new Predication("flag",cb));
                if ((mask&4)!=0) facts.add(new Predication("s_type_mutable",ca));
                if ((mask&8)!=0) facts.add(new Predication("s_type_mutable",cb));
                Expression init = facts.size() == 1 ? facts.get(0) : new Conjunction(facts.toArray(new Expression[facts.size()]));
                HashState nativeTree = new HashState(new AxiomTree(original)); nativeTree.impose(init);
                HashState linear = new HashState(reference); linear.impose(init);
                HashState opt = new HashState(optimized); opt.impose(init);
                require(literals(nativeTree).equals(literals(linear)), "Linear/reference mismatch " + mask);
                require(literals(linear).equals(literals(opt)), "Static simplification mismatch " + mask);
                checks += 2;
            }
            System.out.println("{\"status\":\"passed\",\"valuations\":16,\"checks\":"+checks+"}");
        } else {
            Plan plan = a.get(Glaive.IO_MANAGER).read(new File(argv[2]), Plan.class);
            GlaivePlan raw = new GlaivePlan("raw-reference", p, reference);
            GlaivePlan opt = new GlaivePlan("simplified-reference", p, optimized);
            require(literals(raw.getCurrentState()).equals(literals(opt.getCurrentState())), "Initial closure mismatch");
            int steps=0;
            for (Step step : plan.steps()) {
                require(raw.getCurrentState().isTrue(step.precondition), "Original model inapplicable step " + steps);
                require(opt.getCurrentState().isTrue(step.precondition), "Optimized inapplicable step " + steps);
                raw.addStep((IntentionalStep)step); opt.addStep((IntentionalStep)step); steps++;
                require(literals(raw.getCurrentState()).equals(literals(opt.getCurrentState())), "State mismatch " + steps);
            }
            boolean goal=raw.getCurrentState().isTrue(p.getGoal());
            require(goal, "Original goal not reached");
            require(raw.countUnexplainedSteps()==opt.countUnexplainedSteps(), "Explanation mismatch");
            require(raw.countOrphans()==opt.countOrphans(), "Orphan mismatch");
            System.out.println("{\"status\":\"replayed_same_states\",\"steps\":"+steps+",\"goal\":"+goal+
                ",\"unexplained\":"+raw.countUnexplainedSteps()+",\"orphans\":"+raw.countOrphans()+
                ",\"original_axioms\":"+original.length+",\"simplified_axioms\":"+simplified.length+"}");
        }
    }
}
