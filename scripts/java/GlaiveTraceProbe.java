import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.glaive.GlaivePlan;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.Literal;

/** Emit native state/intentions after initial closure and every executed step.
 * Input is an explicitly registered executed-step projection, never a search.
 */
public class GlaiveTraceProbe {
    private static String quote(String text) {
        return "\"" + text.replace("\\", "\\\\").replace("\"", "\\\"")
            .replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t") + "\"";
    }
    private static void snapshot(GlaivePlan plan, IntentionalProblem problem, int step) {
        ArrayList<String> literals = new ArrayList<String>();
        for (Literal literal : plan.getCurrentState()) literals.add(literal.toString());
        Collections.sort(literals);
        StringBuilder out = new StringBuilder("{\"kind\":\"state\",\"step\":" + step + ",\"literals\":[");
        for (int i = 0; i < literals.size(); i++) {
            if (i > 0) out.append(',');
            out.append(quote(literals.get(i)));
        }
        out.append("],\"goal\":").append(plan.getCurrentState().isTrue(problem.getGoal()));
        out.append(",\"unexplained_steps\":").append(plan.countUnexplainedSteps());
        out.append(",\"orphan_steps\":").append(plan.countOrphans()).append('}');
        System.out.println(out.toString());
    }
    public static void main(String[] argv) {
        int steps = 0;
        try {
            ArgumentMap a = new Glaive().makeArguments();
            a.set(Glaive.DOMAIN, argv[0]); a.set(Glaive.PROBLEM, argv[1]);
            IntentionalProblem p = a.get(Glaive.PROBLEM);
            GlaivePlan replay = new GlaivePlan("trace", p, a.get(Glaive.AXIOM_TREE));
            snapshot(replay, p, 0);
            Plan input = a.get(Glaive.IO_MANAGER).read(new File(argv[2]), Plan.class);
            for (Step step : input.steps()) {
                if (!(step instanceof IntentionalStep)) throw new IllegalArgumentException("Lost intentional step");
                if (!replay.getCurrentState().isTrue(step.precondition)) {
                    System.out.println("{\"kind\":\"result\",\"status\":\"inapplicable_step\",\"completed_steps\":" + steps + "}");
                    System.exit(2);
                }
                replay.addStep((IntentionalStep) step);
                snapshot(replay, p, ++steps);
            }
            System.out.println("{\"kind\":\"result\",\"status\":\"trace_complete\",\"completed_steps\":" + steps + ",\"search_calls\":0}");
        } catch (Exception ex) {
            System.out.println("{\"kind\":\"result\",\"status\":\"runtime_or_parse_error\",\"completed_steps\":" + steps + ",\"error\":" + quote(ex.toString()) + "}");
            System.exit(1);
        }
    }
}
