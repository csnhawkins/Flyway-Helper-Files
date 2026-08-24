---
applyTo: "migrations/**"
---

Files in this folder are generated output, not hand-written SQL - Flyway produces them from the
schema model in `schema-model/`. Don't edit anything here directly, even for a small fix.

If something in a generated migration is wrong: fix the schema model instead, then regenerate the
migration from it (`/flyway-generate-migration`). This keeps the schema model and the migration
scripts as the same source of truth, rather than letting them drift apart silently.
