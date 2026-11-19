import java.util.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Evaluate immutable compiler membership guards in grounded axiom contexts.
 * Effects and mutable predicates remain untouched; the parameterized domain
 * and original problem remain the validation reference.
 */
public class GlaiveStaticAxiomFilter {
    public static ImmutableSet<Axiom> filter(IntentionalProblem problem, Iterable<Axiom> axioms) {
        Set<Predication> writes = new HashSet<>();
        for (Operator op : problem.domain.operators) op.effect.collect(Predication.class, writes);
        for (AxiomTemplate ax : problem.domain.axioms) ax.implies.collect(Predication.class, writes);
        Set<String> modified = new HashSet<>();
        for (Predication p : writes) modified.add(p.predicate);
        HashState initial = new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
        initial.impose(problem.getInitialState());
        LinkedHashSet<Axiom> result = new LinkedHashSet<>();
        for (Axiom axiom : axioms) {
            HashSubstitution values = new HashSubstitution();
            for (Predication p : axiom.context.collect(Predication.class))
                if (p.isGround() && !modified.contains(p.predicate) &&
                    ((p.terms.length == 1 && p.predicate.contains("_type_")) ||
                     (p.terms.length == 0 && p.predicate.endsWith("_active"))))
                    values.replace(p, initial.isTrue(p) ? Expression.TRUE : Expression.FALSE);
            Expression context = axiom.context.substitute(values);
            if (context != Expression.FALSE) result.add(new Axiom(context, axiom.implies));
        }
        return new ImmutableSet<Axiom>(result, Axiom.class);
    }
}
