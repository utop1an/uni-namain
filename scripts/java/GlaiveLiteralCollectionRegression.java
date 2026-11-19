import java.lang.reflect.Method;
import java.util.*;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.ss.*;
import com.stephengware.java.planware.ground.*;

/** Original TreeSet collection is an independent reference, including order. */
public class GlaiveLiteralCollectionRegression {
    public static void main(String[] args) throws Exception {
        ArgumentMap a=new Glaive().makeArguments();
        a.set(Glaive.DOMAIN,args[0]);a.set(Glaive.PROBLEM,args[1]);
        IntentionalProblem p=a.get(Glaive.PROBLEM);
        Method old=ReferenceStateSpace.class.getDeclaredMethod("collectLiterals",Set.class,Set.class,Problem.class);
        Method now=StateSpace.class.getDeclaredMethod("collectLiterals",Set.class,Set.class,Problem.class);
        old.setAccessible(true);now.setAccessible(true);
        Random random=new Random(909115);
        ArrayList<Literal> literals=new ArrayList<>();
        for(int i=0;i<12;i++) {
            Predication q=new Predication("atom"+(i%4), p.universe.objects.get(i%p.universe.objects.length));
            literals.add(q);literals.add(q.negate());
            literals.add(new Predication(q.predicate,q.terms.get(0)));
        }
        literals.add(Expression.TRUE);literals.add(Expression.FALSE);
        int checks=0;
        for(int trial=0;trial<500;trial++) {
            Set<Step> steps=new LinkedHashSet<>();Set<Axiom> axioms=new LinkedHashSet<>();
            for(int j=0;j<40;j++) {
                Expression pre=new Conjunction(literals.get(random.nextInt(literals.size())),literals.get(random.nextInt(literals.size())));
                Expression effect=new Conjunction(literals.get(random.nextInt(literals.size()-2)),literals.get(random.nextInt(literals.size()-2)));
                steps.add(new Step("s"+j,pre,effect));
            }
            for(int j=0;j<8;j++)axioms.add(new Axiom(literals.get(random.nextInt(literals.size())),literals.get(random.nextInt(literals.size()-2))));
            @SuppressWarnings("unchecked") Set<Literal> before=(Set<Literal>)old.invoke(null,steps,axioms,p);
            @SuppressWarnings("unchecked") Set<Literal> after=(Set<Literal>)now.invoke(null,steps,axioms,p);
            if(!new ArrayList<Literal>(before).equals(new ArrayList<Literal>(after)))throw new AssertionError("Literal set/order changed: "+trial);
            checks++;
        }
        Grounder<IntentionalProblem> g=new Grounder<>(p);
        g.setObjectGrounder(Operator.class,new GlaiveStaticGuardGrounder(p));
        g.setObjectGrounder(AxiomTemplate.class,new GlaiveStaticAxiomGrounder(p));
        ReferenceStateSpace before=new ReferenceStateSpace(g);
        StateSpace after=new StateSpace(g);
        if(!Arrays.equals(before.literals.toArray(),after.literals.toArray()))throw new AssertionError("Fixture literals changed");
        if(!before.steps.equals(after.steps) || !before.axioms.equals(after.axioms))throw new AssertionError("Grounding changed");
        System.out.println("{\"status\":\"passed\",\"random_order_checks\":"+checks+",\"ground_steps\":"+after.steps.length+",\"ground_literals\":"+after.literals.length+"}");
    }
}
