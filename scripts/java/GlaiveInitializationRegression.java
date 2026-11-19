package com.stephengware.java.planware.ig;

import java.util.*;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.ss.IntentionalStateSpace;
import com.stephengware.java.planware.util.ImmutableSet;
import com.stephengware.java.planware.util.ImmutableArray;

/** Finite truth tables, ordered eager/lazy rule lookup, and the unchanged
 * exhaustive GoalTree traversal as independent small-graph reference. */
public class GlaiveInitializationRegression {
    static final Random random=new Random(83117);
    static final Predication[] atoms=new Predication[6];
    static int checks=0;
    static void require(boolean ok,String detail){checks++;if(!ok)throw new AssertionError(detail);}
    static Expression literal(){Predication p=atoms[random.nextInt(atoms.length)];return random.nextBoolean()?p:p.negate();}
    static Expression formula(int depth){
        if(depth==0 || random.nextInt(3)==0)return literal();
        Expression a=formula(depth-1),b=formula(depth-1);
        return random.nextBoolean()?new Conjunction(a,b):new Disjunction(a,b);
    }
    static HashState state(int mask){
        HashState state=new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
        for(int i=0;i<atoms.length;i++)if((mask&(1<<i))!=0)state.impose(atoms[i]);
        return state;
    }
    static List<String> applicable(AxiomTree tree,State state){
        List<String> result=new ArrayList<>();Iterator<Axiom> it=tree.getApplicableAxioms(state);
        while(it.hasNext())result.add(it.next().toString());return result;
    }
    public static void main(String[] args) throws Exception {
        for(int i=0;i<atoms.length;i++)atoms[i]=new Predication("p"+i);
        // Empty flattened clauses exercise zero/singleton identities too.
        List<Expression> formulas=new ArrayList<>();
        for(int i=0;i<400;i++)formulas.add(formula(3));
        formulas.add(new Conjunction(new Disjunction(Expression.FALSE,Expression.FALSE),atoms[0]));
        formulas.add(new Disjunction(new Conjunction(Expression.TRUE,Expression.TRUE),atoms[0]));
        for(Expression f:formulas){
            Expression dnf=f.toDNF(),cnf=f.toCNF();
            require(NormalFormUtilities.isDNF(dnf),"Not DNF: "+f);
            require(NormalFormUtilities.isCNF(cnf),"Not CNF: "+f);
            for(int mask=0;mask<64;mask++){
                HashState s=state(mask);
                require(s.isTrue(f)==s.isTrue(dnf),"DNF truth changed: "+f+" / "+mask);
                require(s.isTrue(f)==s.isTrue(cnf),"CNF truth changed: "+f+" / "+mask);
            }
        }
        // Vary query order and revisit states to exercise cached null branches.
        for(int trial=0;trial<120;trial++){
            Set<Axiom> rules=new LinkedHashSet<>();
            for(int i=0;i<10;i++)rules.add(new Axiom(formula(2),literal()));
            ImmutableSet<Axiom> axioms=new ImmutableSet<>(rules,Axiom.class);
            AxiomTree eager=new ReferenceAxiomTree(axioms),lazy=new AxiomTree(axioms);
            List<Integer> masks=new ArrayList<>();for(int i=0;i<64;i++)masks.add(i);
            Collections.shuffle(masks,random);masks.addAll(new ArrayList<>(masks));
            for(int mask:masks)require(applicable(eager,state(mask)).equals(applicable(lazy,state(mask))),"Rule order changed: "+trial+" / "+mask);
        }
        ArgumentMap arguments=new Glaive().makeArguments();arguments.set(Glaive.DOMAIN,args[0]);arguments.set(Glaive.PROBLEM,args[1]);
        IntentionalProblem original=arguments.get(Glaive.PROBLEM);
        IntentionalProblem problem=new IntentionalProblem("finite-control",original.domain,original.universe,Expression.TRUE,Expression.TRUE);
        Constant agent=problem.universe.objects.get(0),other=problem.universe.objects.get(1);
        for(int trial=0;trial<1200;trial++){
            Set<IntentionalStep> steps=new LinkedHashSet<>();Set<Axiom> rules=new LinkedHashSet<>();Set<Literal> literals=new LinkedHashSet<>();
            for(Predication atom:atoms){literals.add(atom);literals.add(atom.negate());}
            for(int i=0;i<9;i++){
                Expression effect=random.nextBoolean()?literal():new Conjunction(literal(),literal());
                Constant who=random.nextInt(4)==0?other:agent;
                steps.add(new IntentionalStep(null,new ImmutableArray<Entity>(new Entity[0]),"s"+i,formula(1),effect,new ImmutableSet<Constant>(new Constant[]{who})));
            }
            for(int i=0;i<7;i++)rules.add(new Axiom(formula(1),literal()));
            IntentionGraph graph=new IntentionGraph(new IntentionalStateSpace(problem,literals,steps,rules));
            GoalNode goal=graph.makeGoalNode(formula(1));
            ReferenceGoalTree ref=ReferenceGoalTree.makeReferenceGoalTree(agent,goal);
            GoalTree opt=GoalTree.makeGoalTree(agent,goal);
            Map<StepNode,Integer> before=new HashMap<>(),after=new HashMap<>();
            for(int i=0;i<ref.steps.length;i++)before.put(ref.steps[i],ref.distances[i]);
            for(int i=0;i<opt.steps.length;i++)after.put(opt.steps[i],opt.distances[i]);
            require(before.equals(after),"Goal ancestry/distances changed in graph "+trial+": "+before+" / "+after);
        }
        System.out.println("{\"status\":\"passed\",\"checks\":"+checks+",\"truth_formulas\":"+formulas.size()+",\"axiom_sets\":120,\"goal_graphs\":1200}");
    }
}
