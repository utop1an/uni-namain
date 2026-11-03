import java.io.File;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.glaive.GlaivePlan;
import com.stephengware.java.planware.ArgumentMap;
import com.stephengware.java.planware.IntentionalDomain;
import com.stephengware.java.planware.IntentionalProblem;
import com.stephengware.java.planware.IntentionalStep;
import com.stephengware.java.planware.Plan;
import com.stephengware.java.planware.Step;

/** A separate no-search parser/replay entry point using the pinned Glaive runtime. */
public class GlaiveProbe {
    public static void main(String[] argv) {
        try {
            Glaive planner = new Glaive();
            ArgumentMap a = planner.makeArguments();
            a.set(Glaive.DOMAIN, argv[1]);
            a.set(Glaive.PROBLEM, argv[2]);
            IntentionalDomain d = a.get(Glaive.DOMAIN);
            IntentionalProblem p = a.get(Glaive.PROBLEM);
            if (argv[0].equals("inspect")) {
                System.out.println("{\"status\":\"parsed\",\"search_calls\":0}");
                return;
            }
            Plan input = a.get(Glaive.IO_MANAGER).read(new File(argv[3]), Plan.class);
            GlaivePlan replay = new GlaivePlan("replay", p, a.get(Glaive.AXIOM_TREE));
            int steps = 0;
            for (Step step : input.steps()) {
                if (!replay.getCurrentState().isTrue(step.precondition))
                    throw new IllegalArgumentException("Inapplicable step " + steps);
                if (!(step instanceof IntentionalStep))
                    throw new IllegalArgumentException("Plan reader did not retain intentional steps");
                replay.addStep((IntentionalStep) step);
                steps++;
            }
            boolean goal = replay.getCurrentState().isTrue(p.getGoal());
            System.out.println("{\"status\":\"replayed\",\"steps\":" + steps +
                ",\"goal\":" + goal + ",\"unexplained_steps\":" + replay.countUnexplainedSteps() +
                ",\"orphan_steps\":" + replay.countOrphans() + ",\"search_calls\":0}");
            if (!goal) System.exit(2);
        } catch (Exception ex) {
            System.err.println(ex.toString());
            System.exit(1);
        }
    }
}
