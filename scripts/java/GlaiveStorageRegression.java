import java.util.*;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.graph.*;
import com.stephengware.java.planware.logic.*;
import com.stephengware.java.planware.util.ImmutableSet;

public class GlaiveStorageRegression {
    static class Item extends Node {
        Item(){super(null);}
        public Iterator<Node> parents(){return Collections.<Node>emptyList().iterator();}
    }
    static class ListUnderTest extends NodeList<Node>{void append(Node n){add(n);}}
    static void require(boolean b,String s){if(!b)throw new AssertionError(s);}
    public static void main(String[] argv){
        ListUnderTest list=new ListUnderTest(); List<Node> expected=new ArrayList<>();
        require(list.size()==0 && !list.contains(null),"Empty list");
        Iterator<Node> empty=list.iterator();
        for(int i=0;i<10000;i++){Node n=i%7==0?null:new Item();list.append(n);expected.add(n);}
        require(!empty.hasNext(),"Iterator is a snapshot");
        Iterator<Node> snapshot=list.iterator(); list.append(new Item());
        int i=0;while(snapshot.hasNext()){require(snapshot.next()==expected.get(i),"Insertion order "+i);i++;}
        require(i==10000 && list.size()==10001 && list.contains(null),"Capacity does not leak into count");
        for(i=0;i<10000;i++)require(list.get(i)==expected.get(i),"Indexed access "+i);
        boolean bounds=false;try{list.get(10001);}catch(ArrayIndexOutOfBoundsException e){bounds=true;}
        require(bounds,"Logical bounds check");
        Predication q=new Predication("q"),r=new Predication("r");
        final Axiom remove=new Axiom(q,q.negate()),stale=new Axiom(q,r);
        AxiomTree ordered=new AxiomTree(new ImmutableSet<Axiom>(new Axiom[0])){
            public Iterator<Axiom> getApplicableAxioms(State s){
                return s.isTrue(q)?Arrays.asList(remove,stale).iterator():Collections.<Axiom>emptyList().iterator();
            }
        };
        HashState state=new HashState(ordered);state.impose(q);
        require(!state.isTrue(q) && !state.isTrue(r),"Do not fire a rule after its context becomes false");
        System.out.println("{\"status\":\"passed\",\"storage_checks\":20004,\"stale_axiom_checks\":1}");
    }
}
