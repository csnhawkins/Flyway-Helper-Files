# Flyway MCP - AI-Assisted Migrations with Guardrails (SQL Server / Chinook)

This repo demonstrates using an AI coding agent (Claude Code, via the Flyway MCP server) to help
manage schema changes for the Chinook SQL Server database with Flyway - **with guardrails**, so
the pattern is safe to run in a live demo and easy for a customer to mimic in their own project.

The pitch: an AI agent can capture schema drift, generate a Flyway migration script, and run a
code review against it - but it never decides on its own to commit, push, branch, open a pull
request, or touch anything beyond a development/shadow database. Those boundaries are enforced by
configuration, not just by asking nicely in a prompt.

## What stops this going wrong

This is the part a customer will ask about first, so it's answered here directly:

| Guardrail | How it's enforced |
|---|---|
| Never touches test/staging/production | This project's `flyway.toml` only defines `development` and `shadow` environments - there's nothing else for the agent to reach |
| Never commits, pushes, or opens a PR on its own | Enforced in `.claude/settings.json` (`git push`, `merge`, `rebase`, `reset`, `pull`, and `gh pr create` are hard-denied) and restated in `CLAUDE.md`. In an interactive session it may commit/branch locally, but only with your confirmation each time |
| Never hand-edits a generated migration | `CLAUDE.md` requires regenerating from an updated schema model instead of patching SQL directly, keeping the model and the script in sync |
| Never silently accepts a destructive change (dropped column, dropped table, renamed object) | `.claude/skills/_shared/flyway-guardrails.md` requires the agent to ask before proceeding (interactive) or flag it as a High-severity issue for human review afterwards (unattended/pipeline) |
| Never ignores a code review finding | `CLAUDE.md` requires every generated migration to go through review, and forbids the agent from deciding a finding doesn't apply |
| Tool access is explicitly scoped, not just prompted | Both automation paths below use `--allowedTools` / `--disallowedTools` (or `.claude/settings.json`) to pre-approve only the Flyway MCP tools needed, rather than relying on the agent choosing to behave |

## Repo layout

```
flyway.toml                  Flyway project config - development/shadow environments only
schema-model/                The schema model - source of truth Flyway diffs against and generates from
migrations/                  Generated, versioned migration scripts (V___/U___) and the baseline
.mcp.json                    Registers the Flyway MCP server for Claude Code
CLAUDE.md                    Project-level rules the agent must follow (workflow order + boundaries)
.claude/settings.json        Enforces those boundaries at the permission layer (allow/deny lists)
.claude/skills/               Two independent skills - deliberately kept separate:
  flyway-capture-schema/       diffs dev DB against the schema model, updates the model
  flyway-generate-migration/   generates a migration script from the model, then code-reviews it
  _shared/                     guardrails and preflight logic both skills reuse
scripts/                      Interactive PowerShell entry point (see below)
AzureDevOps/                  CI/CD pipeline YAML, including the unattended AI version (see below)
```

## Two ways to run this

**1. Interactive, human-in-the-loop** - `scripts/Flyway-AI-MCP_CaptureSchemaModelAndMigration.ps1`

Runs the same workflow as the pipeline below, but pauses for your approval after capture and again
after generation/review, and lets you ask Claude follow-up questions about the change before
deciding whether to commit. Good for day-to-day ad hoc migration work, or for showing someone how
the Flyway MCP server actually behaves step by step. Edit the variables at the top of the script
for your own Azure DevOps collection/project/repo before running it; the Flyway project path is
resolved automatically from the script's own location, so this works wherever the repo is cloned.

**2. Unattended, CI/CD** - `AzureDevOps/AzureDevOps-Flyway-CICD-Pipeline-AI_Windows.yml`

Runs headlessly on a schedule or on demand: captures changes, generates a script, code-reviews it,
and - only if the review is clean or a human approves despite flagged issues - raises a branch and
pull request for a person to merge. It never merges anything itself. See the "ONE-TIME SETUP" and
"KNOWN LIMITATIONS" comments at the bottom of that file before running it for real; in particular,
never add `--dangerously-skip-permissions` or a `--permission-mode` bypass to the AI agent step -
either one silently overrides `--disallowedTools` and removes every guardrail above.

There are also two non-AI pipelines in `AzureDevOps/` (`...-Build_Windows.yml` and the standard
`...-Pipeline_Windows.yml`) for plain Flyway CI/CD without an AI agent involved, useful for
comparing "with AI assistance" against the baseline.

## Getting started

1. Install and license the [Flyway CLI](https://documentation.red-gate.com/fd) (Enterprise, for
   the MCP server) and [Claude Code](https://docs.claude.com/claude-code).
2. Point `flyway.toml` / `flyway.user.toml` (gitignored - create your own from `flyway.toml`'s
   settings) at your own `development` and `shadow` SQL Server instances.
3. Run `claude` interactively once in this folder and accept the "New MCP server found in
   `.mcp.json`: flyway" trust prompt - every automated run above depends on this having happened
   at least once first.
4. Try the interactive script (`scripts/Flyway-AI-MCP_CaptureSchemaModelAndMigration.ps1`) against
   your dev database to see the full workflow end to end before wiring up the unattended pipeline.

## Mimicking this pattern elsewhere

The design deliberately keeps three things separate so they're easy to copy into another project:

- **What the agent is allowed to do** lives in `.claude/settings.json` (interactive) and in each
  automation entry point's own `--allowedTools`/`--disallowedTools` flags (headless) - not
  scattered across prompts.
- **What the agent should do, and why** lives in `CLAUDE.md` and `.claude/skills/` - workflow
  order, naming conventions, and the reasoning behind each boundary.
- **Capture vs. generate are separate skills.** Don't combine them into one - a request to "just
  check for changes" should never accidentally generate a migration script too, and vice versa.

Copy this folder structure, repoint `flyway.toml` at a different database, and adjust
`CLAUDE.md`/`.claude/settings.json` for the new project's own naming conventions and environment
names - the rest of the pattern carries over unchanged.
