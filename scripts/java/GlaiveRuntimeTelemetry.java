import java.io.*;
import java.lang.management.*;
import java.util.*;

/** Diagnostic-only wrapper: sample heap, GC and planner stacks without changing inputs. */
public class GlaiveRuntimeTelemetry {
    private static String quote(String value) {
        return "\""+value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r")+"\"";
    }
    public static void main(String[] args) throws Exception {
        final PrintWriter out = new PrintWriter(new OutputStreamWriter(new FileOutputStream(args[0]), "UTF-8"));
        final long start = System.nanoTime();
        final ThreadMXBean threads = ManagementFactory.getThreadMXBean();
        final MemoryMXBean memory = ManagementFactory.getMemoryMXBean();
        Thread observer = new Thread(() -> {
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    MemoryUsage heap = memory.getHeapMemoryUsage();
                    long count = 0, gcMillis = 0;
                    for (GarbageCollectorMXBean gc : ManagementFactory.getGarbageCollectorMXBeans()) {
                        count += Math.max(0, gc.getCollectionCount());
                        gcMillis += Math.max(0, gc.getCollectionTime());
                    }
                    StringBuilder stacks = new StringBuilder();
                    for (ThreadInfo info : threads.dumpAllThreads(false, false)) {
                        if (info.getThreadName().equals("runtime-telemetry")) continue;
                        StackTraceElement[] frames = info.getStackTrace();
                        boolean planner = info.getThreadName().equals("main");
                        for (StackTraceElement f : frames)
                            planner |= f.getClassName().startsWith("com.stephengware.");
                        if (!planner) continue;
                        if (stacks.length() > 0) stacks.append(',');
                        stacks.append("{\"thread\":").append(quote(info.getThreadName()))
                            .append(",\"cpu_nanos\":").append(threads.getThreadCpuTime(info.getThreadId()))
                            .append(",\"state\":").append(quote(info.getThreadState().toString())).append(",\"frames\":[");
                        for (int i = 0; i < Math.min(16, frames.length); i++) {
                            if (i > 0) stacks.append(',');
                            stacks.append(quote(frames[i].toString()));
                        }
                        stacks.append("]}");
                    }
                    synchronized(out) {
                        out.println("{\"seconds\":"+(System.nanoTime()-start)/1e9+
                            ",\"heap_used\":"+heap.getUsed()+",\"heap_committed\":"+heap.getCommitted()+
                            ",\"heap_max\":"+heap.getMax()+",\"gc_count\":"+count+
                            ",\"gc_millis\":"+gcMillis+",\"threads\":["+stacks+"]}");
                        out.flush();
                    }
                    Thread.sleep(1000);
                } catch (InterruptedException done) { break; }
            }
        }, "runtime-telemetry");
        observer.setDaemon(true);
        observer.start();
        try { GlaiveOptimized.main(Arrays.copyOfRange(args, 1, args.length)); }
        finally { observer.interrupt(); observer.join(1000); synchronized(out) { out.close(); } }
    }
}
