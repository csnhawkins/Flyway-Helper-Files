---
name: flyway-capture-schema
description: Diffs a target database against the Flyway schema model and updates the model to match - the "capture" half of the Flyway MCP workflow, using the Flyway MCP tools (mcp__flyway__*). Use this whenever asked to check for, capture, or record schema changes, or to update/refresh the schema model - even if the request doesn't mention "Flyway" or "MCP" by name (e.g. "what's changed in the dev database", "capture my schema changes", "update the schema model"). This skill ONLY captures changes into the schema model - it does not generate a migration script or run a code review. If a migration script is also wanted, that's the separate flyway-generate-migration skill.
allowed-tools: mcp__flyway__load_project, mcp__flyway__reload_project, mcp__flyway__create_diff_schema_model, mcp__flyway__get_diff_details, mcp__flyway__update_schema_model, Read, Bash(git fetch:*), Bash(git status:*), Bash(git log:*)
---

# Flyway - Capture Schema Changes

Diffs a database against the Flyway schema model and updates the model to reflect what's actually
there. This is one of two independent Flyway MCP skills - it does not generate a migration script.
If a script is also wanted, that's `flyway-generate-migration`, a separate skill for a separate
request. Don't try to do both because the request looked like it might eventually need both -
just do this one job.

## Step 0: preflight check

Before anything else, run the check described in `../_shared/flyway-preflight.md` - confirms the
local checkout isn't behind on migrations before you diff a potentially shared database. This is
mandatory, not optional, and comes before Step 1 below.

## Steps

1. **`load_project`** (or `reload_project` if a project is already loaded and might be stale) -
   always first. Every other tool depends on an active workspace.
2. **`create_diff_schema_model`** - diff the target database against the current schema model.
   Never assume the schema model is already up to date; always check.
3. **`get_diff_details`** - for every change the diff reports, get the actual detail before doing
   anything else with it. "The TrackReview table changed" is not useful to anyone; "dropped column
   ReviewText (nvarchar(1000))" is. Never describe a change as "added", "edited", or "dropped"
   without also saying what specifically was added, edited, or dropped - the column, the type, the
   constraint, whichever applies.
4. **`update_schema_model`** - capture the changes once you understand what they actually are.

That's the whole job. There's no migration-generation tool available to this skill - that's
deliberate, not an oversight.

See `../_shared/flyway-guardrails.md` for how to handle destructive/ambiguous changes, environment
scope, and what this skill doesn't do - those rules apply here in full.

## Shared development databases: don't assume every change is the user's

A development database is often shared, and a diff can surface changes someone else put there for
their own work-in-progress - the database has no way to record whose change is whose. If anything
in the diff doesn't match what the user described working on, call it out individually and confirm
before capturing it into the schema model, the same way you would for a destructive change. Never
fold an unexplained change into the capture silently just because the diff tool reported it.

## Output format

**If the calling prompt asks for structured/JSON output** (an automation script or pipeline will
say so explicitly - look for it), respond with ONLY a single, raw JSON object and nothing else,
even if there was nothing to do. Do not wrap it in a markdown code fence. Do not add commentary
before or after it. Use exactly these field names:

```json
{
  "status": "captured" | "no_changes",
  "changes": [
    {"type": "Add | Edit | Drop", "object": "<schema.object>", "objectType": "<Table|View|Procedure|...>", "details": "<specific - e.g. 'Dropped column ReviewText (nvarchar(1000))', not 'edited'>"}
  ],
  "issues": ["<issue text, including anything you'd normally have asked about, prefixed with its severity>", "..."]
}
```

If there were no changes at all, still reply with exactly this shape:

```json
{"status": "no_changes", "changes": [], "issues": []}
```

**Otherwise** (a person is talking to you directly, no structured-output instruction was given),
just communicate naturally - a short explanation of what you found and captured is more useful to
a person reading a terminal than a JSON blob.