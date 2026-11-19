import java.util.*;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

public class GlaiveAxiomGroundingRegression {
    static class Linear extends AxiomTree {
        final List<Axiom> rules=new ArrayList<>();
        Linear(Set<Axiom> axioms){
            super(new ImmutableSet<Axiom>(new Axiom[0]));
            for(Axiom ax:axioms)if(ax.getPreconditionClauses().size()<=1)rules.add(ax);
            else for(Clause c:ax.getPreconditionClauses())rules.add(new Axiom(c.expression,ax.implies));
        }
        @Override public Iterator<Axiom> getApplicableAxioms(State state){
            List<Axiom> result=new ArrayList<>();for(Axiom ax:rules)if(state.isTrue(ax.context))result.add(ax);return result.iterator();
        }
    }
    static Set<String> facts(State state){Set<String> out=new TreeSet<>();for(Literal l:state)out.add(l.toString());return out;}
    public static void main(String[] args) throws Exception {
        ArgumentMap a=new Glaive().makeArguments();a.set(Glaive.DOMAIN,args[0]);a.set(Glaive.PROBLEM,args[1]);IntentionalProblem p=a.get(Glaive.PROBLEM);
        Grounder<IntentionalProblem> raw=new Grounder<>(p),filtered=new Grounder<>(p);
        filtered.setObjectGrounder(AxiomTemplate.class,new GlaiveStaticAxiomGrounder(p));
        int[] expected={1,2,2,2,0,1,0,0,0,0};
        int[] rawExpected={2,2,2,2,0,2,2,0,2,2};int i=0,checks=0;
        if(p.domain.axioms.length!=expected.length)throw new AssertionError("Fixture denominator: actual="+p.domain.axioms.length);
        Set<Axiom> original=new LinkedHashSet<>(),kept=new LinkedHashSet<>();
        for(AxiomTemplate ax:p.domain.axioms){
            Set<Axiom> all=raw.ground(ax,Axiom.class),part=filtered.ground(ax,Axiom.class);
            if(all.size()!=rawExpected[i] || part.size()!=expected[i] || !all.containsAll(part))throw new AssertionError("Template "+i+": raw="+all.size()+", kept="+part.size());
            checks+=3;original.addAll(all);kept.addAll(part);i++;
        }
        if(i!=expected.length)throw new AssertionError("Fixture denominator: actual="+i+", expected="+expected.length);
        Constant ca=null,cb=null;for(Constant c:p.universe.objects){if(c.name.equals("a"))ca=c;if(c.name.equals("b"))cb=c;}
        for(int mask=0;mask<16;mask++){
            List<Expression> init=new ArrayList<>();init.add(p.getInitialState());
            if((mask&1)!=0)init.add(new Predication("flag",ca));if((mask&2)!=0)init.add(new Predication("flag",cb));
            if((mask&4)!=0)init.add(new Predication("s_type_mutable",ca));if((mask&8)!=0)init.add(new Predication("s_type_mutable",cb));
            Expression initial=init.size()==1?init.get(0):new Conjunction(init);
            HashState before=new HashState(new Linear(original)),after=new HashState(new Linear(kept));before.impose(initial);after.impose(initial);
            if(!facts(before).equals(facts(after)))throw new AssertionError("Closure changed "+mask);checks++;
        }
        System.out.println("{\"status\":\"passed\",\"checks\":"+checks+",\"templates\":"+i+",\"valuations\":16,\"raw_axioms\":"+original.size()+",\"kept_axioms\":"+kept.size()+"}");
    }
}
