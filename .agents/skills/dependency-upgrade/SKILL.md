---
name: dependency-upgrade
description: Upgrade dependencies carefully, assess breaking changes, and apply the minimum required code updates.
---

When invoked:

1. Identify current and target versions.
2. Check changelog/migration cues in the repository or installed docs if available.
3. Update the dependency with the smallest safe code changes.
4. Run relevant tests/build checks.
5. Summarize:
   - package upgraded
   - breaking changes addressed
   - residual risks

Rules:
- Minimize unrelated cleanup.
- Preserve behavior unless the upgrade requires changes.
