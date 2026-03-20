---
name: api-builder
description: Build or modify API endpoints following existing schema, validation, and error-handling conventions.
---

When invoked:

1. Find existing API patterns first.
2. Implement endpoint/controller/service changes consistently.
3. Add validation, typed inputs/outputs, and structured error handling.
4. Update API docs/specs/tests if present.
5. Report:
   - endpoint changed
   - request/response shape
   - validation added
   - tests/docs updated

Rules:
- Reuse existing middleware, serializers, and error formats.
- Do not invent a new API style if one already exists.
