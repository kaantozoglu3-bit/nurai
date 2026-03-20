---
name: shell-automation
description: Safely orchestrate common terminal workflows such as setup, lint, test, build, and cleanup.
disable-model-invocation: true
---

When invoked:

1. Detect available scripts and tooling first.
2. Prefer existing project commands over custom shell one-liners.
3. Execute tasks in a safe order:
   - install/setup if needed
   - lint/format
   - targeted tests
   - build
4. Summarize results and failures clearly.

Rules:
- Avoid destructive commands unless explicitly requested.
- Prefer idempotent commands.
- If a script exists, use it instead of reinventing the process.
