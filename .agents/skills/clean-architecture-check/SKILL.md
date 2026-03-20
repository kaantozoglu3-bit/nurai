---
name: clean-architecture-check
description: Inspect code for architectural drift, layering problems, duplication, and maintainability risks.
---

When invoked:

Inspect for:
- oversized modules
- long functions
- circular dependencies
- layer violations
- duplicated logic
- poor naming
- mixed responsibilities

Return:
- top issues first
- evidence for each
- concrete refactoring suggestions

Rules:
- Focus on meaningful design problems, not trivia.
- Tie suggestions to actual code structure.
