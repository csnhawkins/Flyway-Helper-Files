---
mode: agent
description: Diff the development database against the Flyway schema model and update the model to match. Does not generate a migration script - that's /flyway-generate-migration.
---

Diff the development database against the current Flyway schema model and update the model to
reflect what's actually there. This is one of two halves of the Flyway MCP workflow - do not
generate a migration script or run a code review as part of this; that's a separate ask
(`/flyway-generate-migration`), only after this step is done and, if working interactively,
approved.

## Before diffing: check this checkout isn't behind

A development database is often shared - a diff can surface changes another developer put there
for their own work-in-progress, which the database has no way to distinguish from yours. Before
diffing, check whether this local checkout is behind on `migrations/` (fetch, then compare local
history for that folder against upstream). If it's behind, say so plainly and ask whether to
continue anyway rather than proceeding silently - don't pull, merge, rebase, or reset on your own.

## Steps

1. **Load the project** first - every other tool depends on an active workspace. Reload it instead
   if one's already loaded and might be stale.
2. **Diff the target database against the schema model.** Never assume the model is already
   current - always check.
3. **Get the full detail of every change the diff reports** before doing anything else with it.
   "The TrackReview table changed" isn't useful; "dropped column ReviewText (nvarchar(1000))" is.
   Never describe a change as "added", "edited", or "dropped" without saying specifically what.
4. **Update the schema model** once you understand what actually changed.

## Destructive or ambiguous changes: ask, don't guess

A dropped column, a dropped table, a narrowed data type, a renamed object, or anything else that
could lose data or break something downstream needs a decision from the person you're working
with, not an assumption. Ask before capturing it into the schema model. The same applies to any
change that doesn't match what they described working on - a shared dev database can easily
contain someone else's in-progress work.

## Environment scope

Only touch the `development`/`shadow` environments this project's `flyway.toml` defines. Never
apply anything to test, staging, or production - those are deployed through CI/CD, not from chat.

That's the whole job - there's no migration-generation step here, deliberately.
