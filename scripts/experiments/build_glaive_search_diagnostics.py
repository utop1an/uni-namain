"""Build a Glaive overlay that reports why the planner's search loop stopped."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError(f"Unexpected pinned Java source near {old!r}")
    return text.replace(old, new)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build(output, javac, jar, node_search, launcher):
    inputs = {str(path.resolve()): sha(path)
              for path in (Path(__file__), javac, jar, node_search, launcher)}
    output.mkdir(parents=True)
    sources = output / "src"
    classes = output / "classes"
    sources.mkdir()
    classes.mkdir()
    (output / "protocol.json").write_text(json.dumps({"input_sha256": inputs}, indent=2), encoding="utf-8")

    search = node_search.read_text(encoding="utf-8")
    search = replace_once(search, "private Result result = null;", """private Result result = null;
    private String stopReason;

    public String getStopReason() {
        return stopReason;
    }""")
    search = replace_once(search, "while(!isDone(endTime, searchLimit)){", """while(true){
                stopReason = limitReached(endTime, searchLimit);
                if(stopReason != null)
                    break;""")
    search = replace_once(search, "if(current == null)\n\t\t\t\t\tbreak;", """if(current == null){
                    stopReason = "frontier_exhausted";
                    break;
                }""")
    search = replace_once(search, "bestNode = current;", 'bestNode = current;\n                    stopReason = "solution";')
    search = replace_once(search, "/* do nothing */", 'stopReason = "memory_limit";')
    search = replace_once(search, "private final boolean isDone(long endTime, int searchLimit){\n"
                          "\t\tif(endTime != -1 && System.currentTimeMillis() >= endTime)\n"
                          "\t\t\treturn true;\n"
                          "\t\tif(searchLimit != -1 && result.visited >= searchLimit)\n"
                          "\t\t\treturn true;\n\t\treturn false;", """private String limitReached(long endTime, int searchLimit){
        if(endTime != -1 && System.currentTimeMillis() >= endTime)
            return "internal_time_limit";
        if(searchLimit != -1 && result.visited >= searchLimit)
            return "node_limit";
        return null;""")
    (sources / "NodeSearch.java").write_text(search, encoding="utf-8")

    entry = launcher.read_text(encoding="utf-8")
    entry = replace_once(entry, "import java.io.File;",
                         "import java.io.File;\nimport com.stephengware.java.planware.search.NodeSearch;")
    entry = replace_once(entry, 'emit("result",",\\"status\\":\\""+(result.getSuccess()?',
                         'String reason = search instanceof NodeSearch ? ((NodeSearch<?>) search).getStopReason() : "unknown";\n'
                         '            emit("result",",\\"stop_reason\\":\\""+reason+"\\",\\"status\\":\\""+(result.getSuccess()?')
    (sources / "GlaiveOptimized.java").write_text(entry, encoding="utf-8")
    with (output / "compile.log").open("xb") as log:
        subprocess.run([str(javac), "--release", "8", "-encoding", "UTF-8", "-cp", str(jar),
                        "-d", str(classes), *map(str, sorted(sources.glob("*.java")))],
                       stdout=log, stderr=subprocess.STDOUT, check=True, timeout=60)
    if any(sha(Path(path)) != digest for path, digest in inputs.items()):
        raise ValueError("Pinned source changed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("output", "javac", "jar", "node-search", "launcher"):
        parser.add_argument("--" + name, type=Path, required=True)
    args = parser.parse_args()
    build(args.output, args.javac, args.jar, args.node_search, args.launcher)
