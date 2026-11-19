package com.stephengware.java.planware;

import java.util.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

/** Original-expression truth tables and independently normalized eager trees. */
public class GlaiveComplexAxiomRegression {
    static final Predication[] atoms = new Predication[6];
    static final Random random = new Random(190811);
    static int checks = 0;
    static void require(boolean ok, String detail) {
        checks++;
        if(!ok) throw new AssertionError(detail);
    }
    static HashState state(int mask) {
        HashState s = new HashState(new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])));
        for(int i=0; i<6; i++) if((mask & (1 << i)) != 0) s.impose(atoms[i]);
        return s;
    }
    static Expression formula(int depth) {
        if(depth == 0) return atoms[random.nextInt(6)];
        Expression a=formula(depth-1), b=formula(depth-1);
        switch(random.nextInt(4)) {
            case 0: return new Conjunction(a,b);
            case 1: return new Disjunction(a,b);
            case 2: return new Negation(new Disjunction(a,b));
            default: return new Negation(new Conjunction(a,b));
        }
    }
    static List<String> applicable(AxiomTree tree, State s) {
        List<String> out=new ArrayList<>();
        Iterator<Axiom> it=tree.getApplicableAxioms(s);
        while(it.hasNext()) out.add(it.next().toString());
        return out;
    }
    public static void main(String[] args) {
        for(int i=0;i<6;i++) atoms[i]=new Predication("p"+i);
        Expression first=new Conjunction(atoms[0],new Negation(new Disjunction(atoms[1],atoms[2])));
        if(args.length>0 && args[0].equals("negative-control")) {
            AxiomTree tree=new AxiomTree(new ImmutableSet<Axiom>(new Axiom[]{new Axiom(first,new Predication("effect"))}));
            applicable(tree,state(1));
            System.out.println("{\"status\":\"completed\"}");
            return;
        }
        List<Expression> formulas=new ArrayList<>();
        formulas.add(first);
        formulas.add(new Negation(new Negation(atoms[0])));
        formulas.add(new Negation(new Disjunction(atoms[0],new Conjunction(atoms[1],atoms[2]))));
        formulas.add(Expression.TRUE);
        formulas.add(Expression.FALSE);
        for(int i=0;i<100;i++) formulas.add(formula(3));
        for(Expression f:formulas) {
            AxiomTree tree=new AxiomTree(new ImmutableSet<Axiom>(new Axiom[]{new Axiom(f,new Predication("effect"))}));
            for(int mask=0;mask<64;mask++) {
                HashState s=state(mask);
                require(!applicable(tree,s).isEmpty() == s.isTrue(f),"Original-context truth mismatch: "+f+" / "+mask);
            }
        }
        for(int trial=0;trial<20;trial++) {
            Set<Axiom> original=new LinkedHashSet<>(), normalized=new LinkedHashSet<>();
            for(int i=0;i<8;i++) {
                Expression f=formula(2);Predication effect=new Predication("e"+i);
                original.add(new Axiom(f,effect));normalized.add(new Axiom(f.toDNF(),effect));
            }
            AxiomTree actual=new AxiomTree(new ImmutableSet<Axiom>(original,Axiom.class));
            AxiomTree expected=new ReferenceAxiomTree(new ImmutableSet<Axiom>(normalized,Axiom.class));
            List<Integer> masks=new ArrayList<>();for(int m=0;m<64;m++)masks.add(m);
            Collections.shuffle(masks,random);masks.addAll(new ArrayList<>(masks));
            for(int mask:masks) require(applicable(actual,state(mask)).equals(applicable(expected,state(mask))),"Normalized rule order mismatch: "+trial+" / "+mask);
        }
        System.out.println("{\"status\":\"passed\",\"checks\":"+checks+",\"original_truth_formulas\":"+formulas.size()+",\"normalized_reference_sets\":20}");
    }
}
