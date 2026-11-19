import com.stephengware.java.glaive.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;

/** Finite authored checks of role interpretation and reflexive types; no search. */
public class GlaivePriorityOneRegression {
    private static int checks = 0;
    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++;
        System.out.println("PASS " + message);
    }
    private static Constant object(IntentionalProblem p, String name) {
        for (Constant c : p.universe.objects) if (c.toString().equals(name)) return c;
        throw new IllegalArgumentException("Missing object " + name);
    }
    public static void main(String[] argv) throws Exception {
        if (argv[0].equals("types")) {
            Type root = Type.UNIVERSAL_SUPERTYPE;
            Type human = Type.getType("human"), noble = Type.getType("noble");
            Type knight = Type.getType("knight"), item = Type.getType("item");
            Taxonomy plain = Taxonomy.EMPTY.addType(human).addType(noble).addType(knight).addType(item)
                .addRelationship(human, knight).addRelationship(noble, knight);
            Taxonomy redundant = plain.addRelationship(knight, knight).addRelationship(item, item);
            Type[] types = {root, human, noble, knight, item};
            for (Type parent : types) for (Type child : types)
                require(plain.hasRelationship(parent, child) == redundant.hasRelationship(parent, child),
                    "reflexive type membership " + parent + " / " + child);
            require(!redundant.hasRelationship(item, knight), "unrelated type membership remains false");
        } else {
            ArgumentMap args = new Glaive().makeArguments();
            args.set(Glaive.DOMAIN, argv[0]); args.set(Glaive.PROBLEM, argv[1]);
            IntentionalProblem problem = args.get(Glaive.PROBLEM);
            Constant giver = object(problem, argv[3]), receiver = object(problem, argv[4]);
            IntentionalStep step = problem.makeStep(argv[2], giver, receiver);
            int expectedAgents = Integer.parseInt(argv[5]);
            int expectedUnexplained = Integer.parseInt(argv[6]);
            require(step.agents.length == expectedAgents, "exact required agent count");
            require(step.agents.contains(giver), "acting giver retained");
            require(step.agents.contains(receiver) == (expectedAgents == 2), "receiver consent role matches explicit interpretation");
            GlaivePlan plan = new GlaivePlan("finite_consent_check", problem, args.get(Glaive.AXIOM_TREE));
            require(!plan.getCurrentState().isTrue(problem.getGoal()), "goal initially false");
            require(plan.getCurrentState().isTrue(step.precondition), "physical action applicable");
            plan.addStep(step);
            require(plan.getCurrentState().isTrue(problem.getGoal()), "physical goal reached");
            require(plan.countUnexplainedSteps() == expectedUnexplained, "intentional explanation requirement retained");
        }
        System.out.println("checks=" + checks + ",search_calls=0");
    }
}
