# Project instructions - Flyway database changes

This project uses Flyway Enterprise to manage schema changes for the Chinook SQL Server database.
A Flyway MCP server is configured in `.vscode/mcp.json` - you have direct tools available to
inspect, capture, and generate changes for this database. Follow this file for any Flyway-related
work in this repo.

Two reusable prompts cover the two halves of this workflow - prefer them over improvising the
steps yourself: `/flyway-capture-schema` (diff the dev database, update the schema model) and
`/flyway-generate-migration` (generate a migration script from the model, then code-review it).
See `.github/prompts/` for what each one actually does.

## Workflow you should follow

When asked to look at, capture, or generate migrations for database changes:

1. **Load the project** before doing anything else - all other tools depend on an active workspace.
2. **Diff the development database against the schema model first.** Never assume the schema model
   is already up to date - always check.
3. **Update the schema model** with the changes you find, unless told otherwise. Ask before applying
   changes if a diff includes anything you're unsure was intentional (e.g. a dropped column, a
   renamed table) - these are the changes most likely to be mistakes rather than real intent.
4. **Generate the migration script** from the updated schema model.
5. **Always run a code review on any migration script you generate**, before telling me it's ready.
   Report the full review result, not just a pass/fail - I want to see rule violations even if you
   think they're minor.
6. **Do not apply changes to any database beyond the development environment.** This project's
   `flyway.toml` should only ever have `development` and `shadow` environments reachable by you -
   test, staging, and production are deployed through the CI/CD pipeline, not by you directly.

## Boundaries

- **You may create a branch and commit on my behalf, but confirm with me before each commit and
  before each branch creation** - don't batch several commits behind one confirmation. **Never
  push, and never open a pull request yourself** - that stays a human action.
- **Never edit a migration script by hand after it's been generated.** If something's wrong with a
  generated script, regenerate it from an updated schema model rather than patching the SQL
  directly - keeps the schema model and the scripts as the source of truth in sync.
- **Never disable or bypass a code review finding.** If the review flags something, report it and
  stop - don't decide on my behalf that a rule doesn't apply.
- Treat this database and project as sensitive. Don't share schema details, data, or generated SQL
  outside of this workspace.

**A note on how much these boundaries are worth relying on:** unlike a tool with a configurable
permission/allow-deny system, these rules are enforced by you reading and following this file, not
by anything that technically blocks a push or a hand-edit if you decided to do it anyway. Treat
that as a reason to follow them more carefully, not less - and it's why `development`'s branch
protection in GitHub is the actual backstop for "nothing merges without a human," not this file.

## Naming and style

- Migration descriptions should be short, specific, and written in plain English (e.g.
  "add offers table and getOffers procedure", not "schema update" or "misc changes").
- Follow existing naming/versioning conventions already present in the `migrations/` folder - don't
  introduce a new convention.
