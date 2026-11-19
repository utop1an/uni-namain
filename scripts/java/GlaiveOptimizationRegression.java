import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import com.stephengware.java.glaive.Glaive;
import com.stephengware.java.planware.*;
import com.stephengware.java.planware.ground.*;
import com.stephengware.java.planware.logic.*;

/** Independent finite controls for immutable membership pruning and hash change. */
public class GlaiveOptimizationRegression {
    static String digest(List<String> lines) throws Exception {
        Collections.sort(lines);
        byte[] b = MessageDigest.getInstance("SHA-256").digest(String.join("\n", lines).getBytes(StandardCharsets.UTF_8));
        StringBuilder out = new StringBuilder(); for (byte x : b) out.append(String.format("%02x", x & 255));
        return out.toString();
    }
    public static void main(String[] argv) throws Exception {
        ArgumentMap a = new Glaive().makeArguments(); a.set(Glaive.DOMAIN, argv[0]); a.set(Glaive.PROBLEM, argv[1]);
        IntentionalProblem p = a.get(Glaive.PROBLEM);
        Grounder<IntentionalProblem> original = new Grounder<>(p);
        Grounder<IntentionalProblem> filtered = new Grounder<>(p);
        filtered.setObjectGrounder(Operator.class, new GlaiveStaticGuardGrounder(p));
        int n = p.universe.objects.length;
        Map<String,Integer> expected = new HashMap<>();
        expected.put("only-member",1); expected.put("dynamic-member",n); expected.put("alternative",n);
        expected.put("intersection",0); expected.put("zero",1); expected.put("set-member",n);
        expected.put("different-roles",1); expected.put("empty-domain",0);
        List<String> all = new ArrayList<>(), kept = new ArrayList<>();
        int checks = 0, total = 0; Set<Integer> hashes = new HashSet<>();
        for (Operator op : p.domain.operators) {
            Set<Step> raw = original.ground(op, Step.class), opt = filtered.ground(op, Step.class);
            if (argv.length > 2 && argv[2].equals("fixture")) {
                if (opt.size() != expected.get(op.name)) throw new AssertionError(op.name + ": " + opt.size());
                if (!raw.containsAll(opt)) throw new AssertionError("Invented ground action");
                checks += 2;
            }
            for (Step step : raw) {
                String line = step + "|" + step.precondition + "|" + step.effect + "|" + ((IntentionalStep)step).agents;
                all.add(line); hashes.add(step.hashCode()); total++;
                Step equal = p.makeStep(op.name, step.arguments.toArray());
                if (!step.equals(equal) || step.hashCode() != equal.hashCode()) throw new AssertionError("Equality/hash contract");
            }
            for (Step step : opt) kept.add(step + "|" + step.precondition + "|" + step.effect + "|" + ((IntentionalStep)step).agents);
        }
        System.out.println("{\"status\":\"passed\",\"checks\":" + checks + ",\"ground_steps\":" + total +
            ",\"hashes\":" + hashes.size() + ",\"raw_digest\":\"" + digest(all) + "\",\"guarded_digest\":\"" + digest(kept) + "\"}");
    }
}
