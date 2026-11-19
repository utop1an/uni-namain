import com.stephengware.java.glaive.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;

/** Finite authored transition checks, not a planning or narrative experiment. */
public class GlaiveIntentionRegression {
    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        System.out.println("PASS " + message);
    }
    private static int intentions(GlaivePlan plan) {
        int n = 0;
        for (Literal literal : plan.getCurrentState()) if (literal instanceof Intention) n++;
        return n;
    }
    private static boolean fact(GlaivePlan plan, String text) {
        for (Literal literal : plan.getCurrentState()) if (literal.toString().equals(text)) return true;
        return false;
    }
    public static void main(String[] argv) throws Exception {
        ArgumentMap args = new Glaive().makeArguments();
        args.set(Glaive.DOMAIN, argv[0]); args.set(Glaive.PROBLEM, argv[1]);
        IntentionalProblem problem = args.get(Glaive.PROBLEM);
        Constant alice = null;
        for (Constant c : problem.universe.objects) if (c.toString().equals("alice")) alice = c;
        GlaivePlan plan = new GlaivePlan("authored_regression", problem, args.get(Glaive.AXIOM_TREE));
        require(!plan.getCurrentState().isTrue(problem.getGoal()), "complex goal initially false");
        plan.addStep(problem.makeStep("adopt", alice));
        require(intentions(plan) == 3, "three complete distinct intentions retained");
        require(!fact(plan, "(p alice)") && !fact(plan, "(q alice)"), "adopting goals does not impose their contents");
        require(!plan.getCurrentState().isTrue(problem.getGoal()), "intention adoption alone does not satisfy goal");
        plan.addStep(problem.makeStep("realize", alice));
        require(plan.getCurrentState().isTrue(problem.getGoal()), "conjunction negation disjunction and universal goal evaluate true");
        require(intentions(plan) == 3, "goal realization does not replace or remove intentions");
        System.out.println("checks=6,search_calls=0");
    }
}
