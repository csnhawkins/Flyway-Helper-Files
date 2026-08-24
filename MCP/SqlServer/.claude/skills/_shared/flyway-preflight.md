# Shared preflight check - branch and migration currency

Referenced by both `flyway-capture-schema` and `flyway-generate-migration`, as a mandatory Step 0
before either skill's own steps. This is a read-only check, not a fix - it surfaces a problem, it
never resolves one on its own.

## Why this exists

Two situations cause real damage if they're missed:

- **A shared development database** may already contain schema changes another developer put
  there for their own work-in-progress. A diff against it can include things that aren't the
  current user's intended change at all.
- **A local checkout that hasn't pulled recently** can be behind teammates who have already pushed
  migrations. Generating a new migration from a stale local view risks picking the same next
  version number someone else already claimed - a collision Flyway would otherwise only catch when
  the migration is applied, not before.

Neither of these is something the schema diff itself can tell you - a database has no concept of
"whose change is this," and a local git checkout doesn't know it's behind until it checks.

## Steps

1. **`git fetch`** (read-only - refreshes remote-tracking information, changes nothing locally).
2. **`git status`** - confirm the current branch and whether it's behind its upstream.
3. **`git log` scoped to the `migrations/` folder**, comparing local history against the
   upstream branch - if commits touching `migrations/` exist upstream that aren't in local
   history, the checkout is behind for exactly the files this workflow cares about.

## What to do with the result

- **If behind:** stop before running either skill's normal steps. Tell the user plainly that the
  local checkout is behind on migrations, list what's new upstream if visible, and recommend
  pulling before continuing. Do not pull, merge, rebase, or reset on their behalf - that's a
  human decision, and this check has no tools available to do it even if asked to.
- **If a migration version number the tools are about to generate next already exists upstream**
  (i.e. a teammate has already pushed a migration with that version), flag this explicitly before
  generating - regenerating with the next free version number is Flyway's normal resolution, but
  it should be a confirmed decision, not a silent one.
- **If up to date:** say so in one line and continue straight into the skill's normal steps -
  this check should not add noise when there's nothing to report.

## What this check will never do

Never run a mutating git command as part of this check - no `pull`, `merge`, `rebase`, `reset`, or
`checkout`. Only `fetch`, `status`, and `log` are in scope. If resolving what's found requires a
git operation beyond that, it's the user's decision and action, not this skill's.