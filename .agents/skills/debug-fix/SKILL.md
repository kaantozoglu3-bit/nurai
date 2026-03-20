---
name: debug-fix
description: Debug runtime, build, test, or integration errors; find root cause and apply the smallest safe fix.
---

When invoked, follow this workflow:

1. Reproduce the bug if possible.
2. Identify the exact failing layer:
   - syntax/build
   - runtime
   - test logic
   - configuration/env
   - integration/API/db
3. Trace the root cause, not just the symptom.
4. Prefer the smallest safe fix that preserves existing behavior.
5. After edits, run the narrowest relevant validation first, then broader checks if needed.
6. Summarize:
   - what failed
   - root cause
   - files changed
   - why the fix is correct
   - remaining risks

Rules:
- Do not do broad refactors unless required for the fix.
- Do not silently change public behavior.
- If multiple fixes are possible, choose the least risky one.
- If the bug cannot be reproduced, say so clearly and use the strongest available evidence.
