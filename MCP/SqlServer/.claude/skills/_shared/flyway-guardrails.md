# Shared guardrails - Flyway MCP skills

Referenced by both `flyway-capture-schema` and `flyway-generate-migration`. These rules apply
regardless of which of the two skills is running.

## Destructive or ambiguous changes: ask, or flag - never guess

A dropped column, a dropped table, a narrowed data type, or anything else that could lose data or
break something downstream needs a decision, not an assumption.

- **If you can pause and wait for a reply** (a normal interactive Claude Code session - no one has
  told you otherwise), ask before proceeding. This is the default.
- **If the calling prompt tells you this is an unattended/non-interactive run** (a pipeline, a
  scheduled job, anything explicitly stating no one is available to answer), do not pause - you
  will simply hang forever waiting for input that can't arrive. Proceed, but record it as a
  **High** severity issue in your output so a human reviews and approves or rejects it afterwards,
  instead of it merging in silently.

Either way, the point is the same: destructive changes get a human decision at some point, one way
or the other. The only thing that changes is *when* that decision happens.

## Environment scope

Only ever touch the environments the project's `flyway.toml` actually defines for interactive use
(typically `development`/`shadow`). Never apply anything to test, staging, or production directly -
those are deployed through CI/CD, not by an AI assistant in a chat session.

## What neither skill covers

Capturing changes, generating a script, and reviewing it are the only things these skills do.
Neither one commits, branches, or opens a pull request - if a project's CLAUDE.md says those are
off-limits, that instruction stands. Neither skill grants any tool access beyond its own
`allowed-tools` list.

## Describe the workflow as intent, not memorised tool names

Follow these as steps to achieve ("get full detail on every change before acting on it"), not tool
names to call from memory - Flyway may rename or add MCP tools in future releases, and the intent
should survive that even if a specific tool name changes.