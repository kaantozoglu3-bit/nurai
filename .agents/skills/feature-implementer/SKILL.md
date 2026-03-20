---
name: feature-implementer
description: Implement a new feature with a clear plan, code changes, tests, and concise rollout notes.
---

When invoked:

1. Convert the request into a short implementation checklist.
2. Identify the files/modules likely involved.
3. Implement in the smallest coherent increments.
4. Add or update tests.
5. Update docs, comments, or examples if user-facing behavior changed.
6. Report:
   - feature added
   - files changed
   - tests added/updated
   - assumptions made

Rules:
- Preserve existing conventions.
- Reuse existing abstractions before adding new ones.
- Call out ambiguity explicitly when behavior had to be inferred.
