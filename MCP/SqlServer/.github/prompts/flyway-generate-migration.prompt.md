---
mode: agent
description: Generate a Flyway migration script from the current schema model and code-review it. Does not diff a database or update the schema model - that's /flyway-capture-schema.
---

Turn whatever's currently captured in the Flyway schema model into a migration script, then run
Flyway's code review against it. This is one of two halves of the Flyway MCP workflow - it does
not diff a database or update the schema model. If the schema model doesn't already reflect the
change expected, say so and ask whether to capture it first (`/flyway-capture-schema`) rather than
assuming it's already current.

## Before generating: check this checkout isn't behind

Check whether this local checkout is behind on `migrations/` (fetch, then compare local history
for that folder against upstream) before generating a new script. A stale checkout risks picking
the same next version number a teammate has already pushed - a collision Flyway would otherwise
only catch when the migration is applied. If behind, say so and ask before continuing.

## Steps

1. **Load the project** first (or reload it if one's already loaded and might be stale).
2. **Diff the schema model against the current migration history, then generate the migration
   script** from that diff.
3. **Run the code review** on what was generated. Never skip this, and never report a result that
   wasn't actually run.

## Never hand-edit what's generated

If something about the generated script looks wrong, regenerate it from an updated schema model
instead of patching the SQL directly - that's what keeps the schema model and the script in sync
as a single source of truth. Don't edit the generated file yourself.

## Never suppress or soften a code review finding

Report the review result exactly as returned - full findings, not just a pass/fail, and never a
severity downgraded because it "felt minor." That decision isn't yours to make on the user's
behalf - report it and stop if something's flagged.

## Naming

Migration descriptions should be short, specific, plain English (e.g. "add offers table and
getOffers procedure" - not "schema update" or "misc changes"). Follow whatever versioning/naming
convention already exists in `migrations/` rather than inventing a new one.
