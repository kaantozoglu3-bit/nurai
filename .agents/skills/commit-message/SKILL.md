---
name: commit-message
description: Generate precise commit messages from the current diff using conventional commits where appropriate.
disable-model-invocation: true
---

When invoked:

1. Inspect the diff.
2. Determine change type:
   - feat
   - fix
   - refactor
   - test
   - docs
   - chore
   - perf
3. Produce:
   - one primary commit message
   - 2-4 alternate options
4. If useful, include a short body explaining why.

Rules:
- Keep subject line concise and specific.
- Mention scope if it adds clarity.
- Do not exaggerate the change.
