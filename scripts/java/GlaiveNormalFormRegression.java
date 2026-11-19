import java.util.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

public class GlaiveNormalFormRegression {
    static Constant[] objects={new Constant("a"),new Constant("b")};
    static Predication p=new Predication("p"),q=new Predication("q");
    static boolean truth(Expression expression,State state){
        if(expression instanceof QuantifiedExpression){
            QuantifiedExpression quantified=(QuantifiedExpression)expression;
            boolean universal=quantified instanceof UniversalQuantification;
            for(Constant object:objects){
                HashSubstitution subst=new HashSubstitution();subst.replace(quantified.variable,object);
                boolean value=truth(quantified.argument.substitute(subst),state);
                if(value!=universal)return !universal;
            }
            return universal;
        }
        if(expression instanceof Conjunction){for(Expression child:((Conjunction)expression).arguments)if(!truth(child,state))return false;return true;}
        if(expression instanceof Disjunction){for(Expression child:((Disjunction)expression).arguments)if(truth(child,state))return true;return false;}
        return state.isTrue(expression);
    }
    static Expression all(String name){TermVariable x=new TermVariable(name);return new UniversalQuantification(x,new Conjunction(new Predication("u",x),new Predication("v",x)));}
    public static void main(String[] args){
        List<Expression> stress=new ArrayList<>();stress.add(new Disjunction(p,q));
        for(int i=0;i<32;i++)stress.add(all("x"+i));
        Expression result=new Conjunction(stress).toDNF();
        if(!(result instanceof Disjunction) || ((Disjunction)result).arguments.length!=2)throw new AssertionError("Incorrect permutation radix");
        if(args.length>0 && args[0].equals("stress")){System.out.println("{\"status\":\"passed\",\"actual_clauses\":2,\"quantified_conjunctions\":32}");return;}
        TermVariable x=new TermVariable("y");
        Expression[] tests={new Conjunction(new Disjunction(p,q),all("x")),
            new Disjunction(new Conjunction(p,q),new ExistentialQuantification(x,new Disjunction(new Predication("u",x),new Predication("v",x))))};
        Literal[] facts={p,q,new Predication("u",objects[0]),new Predication("v",objects[0]),new Predication("u",objects[1]),new Predication("v",objects[1])};int checks=1;
        for(Expression expression:tests)for(int mask=0;mask<64;mask++){
            HashState state=new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
            for(int i=0;i<6;i++)if((mask&(1<<i))!=0)state.impose(facts[i]);
            boolean expected=truth(expression,state);
            if(expected!=truth(expression.toDNF(),state) || expected!=truth(expression.toCNF(),state))throw new AssertionError("Quantified truth changed "+mask);
            checks+=2;
        }
        System.out.println("{\"status\":\"passed\",\"checks\":"+checks+",\"quantified_valuations\":128,\"stress_clauses\":2}");
    }
}
