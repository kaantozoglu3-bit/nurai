---
name: refactor-safe
description: Improve structure and readability while preserving behavior and public interfaces.
---

When invoked:

1. Map the affected module boundaries first.
2. Identify duplication, oversized functions, poor naming, and coupling.
3. Refactor in small safe steps.
4. Preserve public APIs unless explicitly told otherwise.
5. Run existing tests or the narrowest relevant checks after changes.
6. Summarize:
   - what improved
   - what behavior was preserved
   - any follow-up refactors still worth doing

Rules:
- Prefer mechanical, reviewable edits.
- Avoid mixing refactor and feature work unless necessary.
- Keep diffs small when possible.
