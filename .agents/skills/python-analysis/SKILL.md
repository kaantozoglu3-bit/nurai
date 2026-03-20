---
name: python-analysis
description: Support Python-based numerical analysis, data cleanup, plotting, and result interpretation.
---

When invoked:

1. Identify the data flow and expected outputs.
2. Check for:
   - missing values
   - dtype issues
   - unit mistakes
   - indexing/grouping errors
3. Keep analysis reproducible.
4. When plotting, choose the simplest plot that answers the question.
5. Summarize key findings clearly.

Rules:
- Prefer explicit transformations over chained opaque logic.
- Do not overcomplicate simple analysis.
