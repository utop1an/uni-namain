import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.Grounder;
import com.stephengware.java.planware.logic.*;

/** Small deterministic regression checks; never invokes planning. */
public class GlaiveRuntimeRegression {
    private static int failed = 0;
    private static void check(String name, boolean ok, String detail) {
        System.out.println(name + "\t" + (ok ? "PASS" : "FAIL") + "\t" + detail);
        if (!ok) failed++;
    }
    private static Constant object(Problem p, String name) {
        for (Constant c : p.universe.objects) if (c.toString().equals(name)) return c;
        throw new IllegalArgumentException(name);
    }
    private static void count(Problem p, String name, int expected) {
        try {
            int n = new Grounder<Problem>(p).ground(p.domain.getOperator(name), Step.class).size();
            check(name, n == expected, "expected=" + expected + ",actual=" + n);
        } catch (Exception ex) { check(name, false, ex.toString()); }
    }
    public static void main(String[] argv) throws Exception {
        ArgumentMap a = new Glaive().makeArguments();
        a.set(Glaive.DOMAIN, argv[0]); a.set(Glaive.PROBLEM, argv[1]);
        IntentionalProblem p = a.get(Glaive.PROBLEM);
        Constant x = object(p, "c1"), y = object(p, "c2");
        Expression allFalse = p.makeStep("boolean-or", x, x, x).precondition;
        Expression mixed = p.makeStep("boolean-or", x, x, y).precondition;
        Expression allTrue = p.makeStep("boolean-or", x, y, y).precondition;
        check("or_all_false", allFalse == Expression.FALSE, allFalse.toString());
        check("or_mixed", mixed == Expression.TRUE, mixed.toString());
        check("or_all_true", allTrue == Expression.TRUE, allTrue.toString());
        count(p, "empty-mixed", 0);
        count(p, "empty-single", 0);
        count(p, "zero-arity", 1);
        count(p, "product-two", 4);
        count(p, "product-one", 2);
        System.out.println("failures=" + failed + ",search_calls=0");
        if (failed != 0) System.exit(1);
    }
}
