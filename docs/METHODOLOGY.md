# Methodology

Loop for every phase:

1. **Hypothesis** - one sentence, what we expect.
2. **Evidence plan** - which tool gives proof (CI analysis, trace, device test).
3. **Run** - automated, one command, output saved under `artifacts/` or CI artifact.
4. **Record** - tool, full command, result, timestamp in `docs/COMMANDS.md` and `docs/CHRONOLOGY.md`.
5. **Decide** - accept / reject / need more evidence. Never claim a root cause without evidence from the failing state.
6. **Commit** - docs and code together.

## Rules
- Heavy work (download, analysis, build) on CI; thinking by Claude; real testing on user hardware.
- The user is asked for at most ONE action per step, preferably zero (MCP automation).
- Every driver change is behind a build that must be green on CI before the user installs anything.
- Facts in `docs/hw/` carry a source tag: `[RE]` official binary, `[LNX]` Linux source, `[TRACE]` USB capture.
- Session end: update PHASES.md, CHRONOLOGY.md, daily log, and memory.
