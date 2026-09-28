## Legacy Parity

When the spec rebuilds an existing system's screens or functions, that system (its running instance and
source) is the specification. Reproduce its layout, texts and behaviour; do not improve, tidy or add
anything. The only permitted differences are the forced changes and dropped items in the spec's parity rows
and the approved suggestions; every other difference is a defect. If legacy behaviour looks wrong, or you
cannot reproduce it in the new system, do not decide: stop, record it under Open questions in the
End-of-Run Report (or under Ambiguities in the plan), and let the user decide. Report every remaining
difference from legacy, with its explanation, under Deviations. Where the project has a gate command for
legacy comparison (named in `AGENT.md`/`PROJECT_AGENT.md` and the spec), run it after every group of
changes; do not report a phase done until it exits zero, paste its final output in the End-of-Run Report,
and look at every side-by-side image it lists (a passing gate is necessary, not sufficient). The gate
fails only on checks, captures and the hack scan; the measured differences it prints are advisory. **You
own "looks right":** write, capture, look, fix. Differences of a few pixels are not defects and are not
chased.

**Look first, then measure.** Work in small groups (one element or one region). After each group, capture,
open the side-by-side image of the affected state with the image viewer, and write one line in the
progress file saying what still looks different (or "matches"). Fix anything visible before you look at
the numbers; the report is a check on what your eyes missed, not the way to find the work. Where the spec
names a reference file of legacy values (source styles and measured values), copy from it instead of
deriving values from the new page.
