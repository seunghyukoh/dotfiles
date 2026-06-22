---
description: Start a loop that periodically monitors an experiment until it finishes, sharing interim results.
argument-hint: [interval (e.g. 30m, omit to self-pace)] [experiment/target to monitor]
---

Use the `loop` skill to start an experiment-monitoring loop with the standard instructions below.

## Argument parsing

- Full arguments: `$ARGUMENTS`
- If the first token is a time format like `30m`, `15m`, `1h`, `45s`, use it as the **loop interval** and treat the rest as the description of what to monitor.
- If the first token is not a time format, omit the interval (let the model self-pace) and treat the entire argument string as the description of what to monitor.
- If the monitoring target is empty, first ask the user once which experiment is currently running (or should be started), then begin the loop.

## Standard monitoring instructions (apply every iteration)

1. **Periodic monitoring & interim sharing**: Check status until the experiment finishes, and on each iteration share progress and key metrics (completion %, loss/metric trends, remaining steps/time, anomalies, etc.) concisely with the user. If nothing has changed, say "no change" explicitly.

2. **Problem-handling branch**:
   - **Simple problems** (e.g. transient OOM you can work around, missing paths/env vars, errors fixed by a retry) — fix them yourself and report what you changed and how.
   - **Hard problems** (design changes, hard-to-reverse actions, unclear root cause, or anything needing the user's judgment) — do not handle them yourself; ask the user with `needs input:` clearly stating what is blocking you.

3. **No-monkeypatching-first principle**: **Before** writing any workaround/patch, first verify that we are using the package/library the **recommended (official) way**.
   - If we were violating the recommended usage → prioritize fixing it to the correct usage (not monkeypatching).
   - Only when the problem remains despite already following the recommended usage should you consider a patch/workaround, and even then handle it per branch #2 above.
   - If the recommended usage is unclear, check the official documentation (Context7 MCP or official docs).

4. **Termination conditions**: When the experiment finishes normally, summarize the final results, close with a single `result:` line, and stop the loop. If it is structurally impossible to proceed, stop with `failed:` and the reason.
