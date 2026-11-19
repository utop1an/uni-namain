import java.util.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Experimental binding filter; preserves the original parameterized model.
 * Only positive, conjunctively required, immutable unary membership predicates
 * constrain a parameter. Disjunctions and quantified conditions are untouched.
 */
public class GlaiveStaticGuardGrounder implements ObjectGrounder<Operator, IntentionalProblem> {
    private final Set<String> modified = new HashSet<>();
    private final HashState initial = new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
    private final OperatorGrounder<IntentionalProblem> fallback = new OperatorGrounder<>();
    public GlaiveStaticGuardGrounder(IntentionalProblem problem) {
        Set<Predication> effects = new HashSet<>();
        for (Operator op : problem.domain.operators) op.effect.collect(Predication.class, effects);
        for (AxiomTemplate ax : problem.domain.axioms) ax.implies.collect(Predication.class, effects);
        for (Predication p : effects) modified.add(p.predicate);
        initial.impose(problem.getInitialState());
    }
    private void required(Expression e, List<Predication> out) {
        if (e instanceof Conjunction)
            for (Expression part : ((Conjunction)e).arguments) required(part, out);
        else if (e instanceof Predication) {
            Predication p = (Predication)e;
            if (p.terms.length == 1 && p.predicate.contains("_type_") && !modified.contains(p.predicate)) out.add(p);
        }
    }
    public Set<Object> ground(Operator op, Grounder<IntentionalProblem> grounder) {
        for (Variable v : op.parameters)
            if (!(v instanceof TermVariable)) return fallback.ground(op, grounder);
        List<Predication> constraints = new ArrayList<>(); required(op.precondition, constraints);
        if (constraints.isEmpty()) return fallback.ground(op, grounder);
        List<List<Entity>> domains = new ArrayList<>();
        for (Variable v : op.parameters) {
            List<Entity> allowed = new ArrayList<>();
            for (Entity value : grounder.ground(v, Entity.class)) {
                boolean keep = true;
                for (Predication p : constraints)
                    if (p.terms.get(0).equals(v) && !initial.isTrue(new Predication(p.predicate, (Term)value))) { keep = false; break; }
                if (keep) allowed.add(value);
            }
            domains.add(allowed);
        }
        Set<Object> result = new LinkedHashSet<>();
        enumerate(op, grounder, domains, new Entity[op.parameters.length], 0, result);
        return result;
    }
    private void enumerate(Operator op, Grounder<IntentionalProblem> g, List<List<Entity>> domains, Entity[] args, int i, Set<Object> result) {
        if (i == args.length) { result.add(g.problem.makeStep(op.name, args.clone())); return; }
        for (Entity value : domains.get(i)) { args[i] = value; enumerate(op, g, domains, args, i + 1, result); }
    }
}
