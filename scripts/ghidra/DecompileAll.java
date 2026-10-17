// Ghidra headless post-script: export everything useful from the analyzed program.
// args: <outDir>
// outputs: decompiled.c, functions.csv (addr,name,size,callers,callees,thunk), callgraph.csv, strings.csv,
//          externals.csv (imports), segments.csv
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.DataIterator;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionManager;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.Set;

public class DecompileAll extends GhidraScript {

    private PrintWriter open(String dir, String name) throws Exception {
        return new PrintWriter(new BufferedWriter(new FileWriter(new File(dir, name)), 1 << 16));
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        String outDir = args.length > 0 ? args[0] : "out";
        new File(outDir).mkdirs();

        try (PrintWriter seg = open(outDir, "segments.csv")) {
            seg.println("name,start,end,size,r,w,x");
            for (MemoryBlock b : currentProgram.getMemory().getBlocks()) {
                seg.println(b.getName() + "," + b.getStart() + "," + b.getEnd() + "," + b.getSize() + ","
                        + b.isRead() + "," + b.isWrite() + "," + b.isExecute());
            }
        }

        try (PrintWriter ext = open(outDir, "externals.csv")) {
            ext.println("library,name,address");
            SymbolIterator it = currentProgram.getSymbolTable().getExternalSymbols();
            while (it.hasNext()) {
                Symbol s = it.next();
                ext.println(s.getParentNamespace().getName() + "," + s.getName() + "," + s.getAddress());
            }
        }

        try (PrintWriter str = open(outDir, "strings.csv")) {
            str.println("address,value");
            DataIterator di = currentProgram.getListing().getDefinedData(true);
            while (di.hasNext()) {
                Data d = di.next();
                if (d.hasStringValue()) {
                    Object v = d.getValue();
                    String s = v == null ? "" : v.toString().replace("\n", "\\n").replace("\r", "\\r");
                    str.println(d.getAddress() + ",\"" + s.replace("\"", "'") + "\"");
                }
            }
        }

        DecompInterface decomp = new DecompInterface();
        decomp.openProgram(currentProgram);
        FunctionManager fm = currentProgram.getFunctionManager();
        int total = fm.getFunctionCount();
        int n = 0, failed = 0;
        try (PrintWriter c = open(outDir, "decompiled.c");
             PrintWriter csv = open(outDir, "functions.csv");
             PrintWriter edges = open(outDir, "callgraph.csv")) {
            csv.println("addr,name,size,callers,callees,thunk");
            edges.println("from,to");
            for (Function f : fm.getFunctions(true)) {
                monitor.checkCancelled();
                long size = f.getBody().getNumAddresses();
                Set<Function> callees = f.getCalledFunctions(monitor);
                Set<Function> callers = f.getCallingFunctions(monitor);
                csv.println(f.getEntryPoint() + "," + f.getName() + "," + size + "," + callers.size() + ","
                        + callees.size() + "," + (f.isThunk() ? 1 : 0));
                for (Function g : callees) {
                    edges.println(f.getEntryPoint() + "," + g.getEntryPoint());
                }
                c.println("// ==== " + f.getName() + " @ " + f.getEntryPoint() + " size=" + size);
                if (f.isThunk() || f.isExternal()) {
                    c.println("// (thunk/external)");
                } else {
                    DecompileResults r = decomp.decompileFunction(f, 90, monitor);
                    if (r != null && r.decompileCompleted() && r.getDecompiledFunction() != null) {
                        c.println(r.getDecompiledFunction().getC());
                    } else {
                        failed++;
                        c.println("// DECOMPILE FAILED: " + (r == null ? "null" : r.getErrorMessage()));
                    }
                }
                n++;
                if (n % 250 == 0) {
                    println("decompiled " + n + " / " + total + " (failed " + failed + ")");
                }
            }
        }
        println("DONE decompiled " + n + " functions, failed " + failed);
        decomp.dispose();
    }
}
