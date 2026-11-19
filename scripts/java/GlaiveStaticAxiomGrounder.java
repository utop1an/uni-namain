import java.util.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Prune only bindings whose required immutable compiler guards are false.
 * Retained axioms are made by the original problem with unchanged contexts. */
public class GlaiveStaticAxiomGrounder implements ObjectGrounder<AxiomTemplate,IntentionalProblem> {
    final Set<String> modified=new HashSet<>();
    final HashState initial=new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
    final AxiomGrounder<IntentionalProblem> fallback=new AxiomGrounder<>();
    public GlaiveStaticAxiomGrounder(IntentionalProblem problem){
        Set<Predication> writes=new HashSet<>();
        for(Operator op:problem.domain.operators)op.effect.collect(Predication.class,writes);
        for(AxiomTemplate ax:problem.domain.axioms)ax.implies.collect(Predication.class,writes);
        for(Predication p:writes)modified.add(p.predicate);
        initial.impose(problem.getInitialState());
    }
    void required(Expression e,List<Predication> guards){
        if(e instanceof Conjunction)for(Expression part:((Conjunction)e).arguments)required(part,guards);
        else if(e instanceof Predication){
            Predication p=(Predication)e;
            if(!modified.contains(p.predicate) && ((p.terms.length==1 && p.predicate.contains("_type_")) ||
                    (p.terms.length==0 && p.predicate.endsWith("_active"))))guards.add(p);
        }
    }
    public Set<Object> ground(AxiomTemplate ax,Grounder<IntentionalProblem> grounder){
        // Preserve the original enumerator's zero-parameter behavior exactly.
        if(ax.parameters.length==0)return fallback.ground(ax,grounder);
        List<Predication> guards=new ArrayList<>();required(ax.context,guards);
        for(Predication p:guards)if(p.isGround() && !initial.isTrue(p))return new LinkedHashSet<>();
        if(guards.isEmpty())return fallback.ground(ax,grounder);
        for(Variable v:ax.parameters)if(!(v instanceof TermVariable))return fallback.ground(ax,grounder);
        List<List<Entity>> domains=new ArrayList<>();
        for(Variable v:ax.parameters){
            List<Entity> allowed=new ArrayList<>();
            for(Entity value:grounder.ground(v,Entity.class)){
                boolean keep=true;
                for(Predication p:guards)
                    if(p.terms.length==1 && p.terms.get(0).equals(v) && !initial.isTrue(new Predication(p.predicate,(Term)value))){keep=false;break;}
                if(keep)allowed.add(value);
            }
            domains.add(allowed);
        }
        int index=-1;for(int i=0;i<grounder.problem.domain.axioms.length;i++)if(grounder.problem.domain.axioms.get(i)==ax){index=i;break;}
        if(index<0)throw new IllegalArgumentException("Unregistered axiom template");
        Set<Object> result=new LinkedHashSet<>();enumerate(index,grounder,domains,new Entity[ax.parameters.length],0,result);return result;
    }
    void enumerate(int index,Grounder<IntentionalProblem> g,List<List<Entity>> domains,Entity[] args,int i,Set<Object> result){
        if(i==args.length){
            Axiom axiom = makeAxiom(g.problem, index, args);
            if (axiom != null) result.add(axiom);
            return;
        }
        for(Entity value:domains.get(i)){args[i]=value;enumerate(index,g,domains,args,i+1,result);}
    }

    private Axiom makeAxiom(IntentionalProblem problem, int index, Entity[] args) {
        try {
            return problem.makeAxiom(index, args.clone());
        } catch (ArithmeticException overflow) {
            if (!"integer overflow".equals(overflow.getMessage())) throw overflow;

            // Quantifier expansion can introduce a disjunction per object. Fold
            // immutable compiler memberships before retrying DNF construction.
            AxiomTemplate template = problem.domain.axioms.get(index);
            HashSubstitution bindings = new HashSubstitution(problem.universe);
            for (int i = 0; i < args.length; i++) bindings.replace(template.parameters.get(i), args[i]);
            Expression context = template.context.substitute(bindings);
            HashSubstitution memberships = new HashSubstitution();
            for (Predication fact : context.collect(Predication.class)) {
                if (fact.isGround() && fact.terms.length == 1 && fact.predicate.contains("_type_")
                        && !modified.contains(fact.predicate))
                    memberships.replace(fact, initial.isTrue(fact) ? Expression.TRUE : Expression.FALSE);
            }
            Expression reduced = context.substitute(memberships);
            if (reduced == context) throw overflow;
            if (reduced == Expression.FALSE) return null;
            return new Axiom(reduced, template.implies.substitute(bindings));
        }
    }
}
