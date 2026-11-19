import java.io.File;
import java.util.*;
import com.stephengware.java.glaive.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.ss.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Offline entry point. Input domain, problem and plans are never rewritten. */
public class GlaiveOptimized {
    static long start = System.nanoTime();
    static void emit(String phase, String fields) {
        System.out.println("{\"phase\":\""+phase+"\",\"elapsed_seconds\":"+((System.nanoTime()-start)/1e9)+fields+"}");
        System.out.flush();
    }
    /** Replay original clauses, including static facts in causal explanations.
     * Linear lookup avoids the old exponential tree-construction cost. Only
     * contexts proved permanently false are discarded; effects stay original.
     */
    public static class OriginalContextTree extends AxiomTree {
        final List<Axiom> rules = new ArrayList<>();
        public OriginalContextTree(IntentionalProblem p, ImmutableSet<Axiom> original) {
            super(new ImmutableSet<Axiom>(new Axiom[0]));
            Set<Predication> writes=new HashSet<>(); Set<String> modified=new HashSet<>();
            for(Operator op:p.domain.operators) op.effect.collect(Predication.class,writes);
            for(AxiomTemplate ax:p.domain.axioms) ax.implies.collect(Predication.class,writes);
            for(Predication fact:writes) modified.add(fact.predicate);
            HashState initial=new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
            initial.impose(p.getInitialState());
            for (Axiom ax : original) {
                HashSubstitution values=new HashSubstitution();
                for(Predication fact:ax.context.collect(Predication.class))
                    if(fact.isGround() && !modified.contains(fact.predicate) &&
                       ((fact.terms.length==1 && fact.predicate.contains("_type_")) ||
                        (fact.terms.length==0 && fact.predicate.endsWith("_active"))))
                        values.replace(fact,initial.isTrue(fact)?Expression.TRUE:Expression.FALSE);
                if(ax.context.substitute(values)==Expression.FALSE) continue;
                if (ax.getPreconditionClauses().size() <= 1) rules.add(ax);
                else for (Clause c : ax.getPreconditionClauses()) rules.add(new Axiom(c.expression,ax.implies));
            }
        }
        @Override public Iterator<Axiom> getApplicableAxioms(State state) {
            List<Axiom> applicable=new ArrayList<>();
            for (Axiom ax : rules) if(state.isTrue(ax.context)) applicable.add(ax);
            return applicable.iterator();
        }
    }
    static ImmutableSet<Axiom> axioms(IntentionalProblem p) {
        Grounder<IntentionalProblem> g=new Grounder<>(p); Set<Axiom> set=new LinkedHashSet<>();
        for(AxiomTemplate t:p.domain.axioms) for(Axiom ax:g.ground(t,Axiom.class))
            if(ax.context!=Expression.FALSE) set.add(ax);
        return new ImmutableSet<Axiom>(set,Axiom.class);
    }
    public static void main(String[] argv) throws Exception {
        String mode=argv[0]; Glaive planner=new Glaive(); ArgumentMap a=planner.makeArguments();
        a.set(Glaive.DOMAIN,argv[1]); a.set(Glaive.PROBLEM,argv[2]);
        emit("parse_begin",""); IntentionalProblem p=a.get(Glaive.PROBLEM); emit("parse_end","");
        if(mode.equals("search")) {
            emit("state_space_begin",""); Grounder<IntentionalProblem> g=new Grounder<>(p);
            g.setObjectGrounder(Operator.class,new GlaiveStaticGuardGrounder(p));
            IntentionalStateSpace space=new IntentionalStateSpace(g);
            emit("state_space_end",",\"steps\":"+space.steps.length+",\"axioms\":"+space.axioms.length);
            emit("axiom_filter_begin",""); ImmutableSet<Axiom> filtered=GlaiveStaticAxiomFilter.filter(p,space.axioms);
            a.set(Glaive.STATE_SPACE,new IntentionalStateSpace(p,space.literals,space.steps,filtered));
            emit("axiom_filter_end",",\"axioms\":"+filtered.length);
            emit("axiom_tree_begin",""); a.get(Glaive.AXIOM_TREE); emit("axiom_tree_end","");
            emit("search_setup_begin",""); Search search=planner.search(a); emit("search_setup_end","");
            a.set(Glaive.TIME_LIMIT,Integer.parseInt(argv[4])*1000);
            emit("search_begin",""); Result result=search.getNextPlan(a);
            if(result.getSuccess()) a.get(Glaive.IO_MANAGER).write(result.getPlan(),new File(argv[3]));
            emit("result",",\"status\":\""+(result.getSuccess()?"solved":"no_solution_returned")+
                "\",\"visited\":"+result.getVisited()+",\"generated\":"+result.getGenerated());
        } else if(mode.equals("replay")) {
            Plan plan=a.get(Glaive.IO_MANAGER).read(new File(argv[3]),Plan.class);
            emit("replay_axioms_begin",""); AxiomTree tree=new OriginalContextTree(p,axioms(p));
            emit("replay_axioms_end",""); GlaivePlan replay=new GlaivePlan("optimized-original-model-replay",p,tree);
            int count=0;
            for(Step step:plan.steps()) {
                if(!(step instanceof IntentionalStep) || !replay.getCurrentState().isTrue(step.precondition))
                    throw new IllegalArgumentException("Inapplicable or nonintentional step "+count);
                replay.addStep((IntentionalStep)step); count++;
            }
            emit("result",",\"status\":\"replayed\",\"goal\":"+replay.getCurrentState().isTrue(p.getGoal())+
                ",\"steps\":"+count+",\"unexplained_steps\":"+replay.countUnexplainedSteps()+",\"orphan_steps\":"+replay.countOrphans());
        } else throw new IllegalArgumentException("Unsupported mode "+mode);
    }
}
