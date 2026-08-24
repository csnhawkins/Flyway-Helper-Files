# Invoke-FlywayAIWorkflow.ps1
#
# Flyway MCP Migration Workflow - Interactive Mode
#
# Runs the same Flyway MCP workflow as the unattended AI pipeline
# (AzureDevOps-Flyway-CICD-Pipeline-AI_Windows.yml), but with a human reviewing and approving at
# every stage instead of running headlessly. Useful for day-to-day ad hoc migration work outside
# CI/CD, hands-on validation of a change before it goes anywhere near a pipeline, or training
# someone new on how the Flyway MCP server actually works.
#
# What this does, step by step:
#   1. Ask Claude to check the dev database and capture any schema changes into the schema model
#      - you'll see its tool calls appear live as it works, not just a final summary
#   2. Show you what it found, in plain English - you approve before it goes further
#   3. Ask Claude to generate a migration script and run a code review on it
#   4. Show you the review result - you can approve, ask Claude follow-up questions about the
#      change (using the same conversation session, so it has full context), or stop here
#   5. If you're happy, choose to either commit locally (you pick the message) or push a
#      feature branch and open a pull request in your browser (you pick the name)
#
# This deliberately does NOT create a pull request via the REST API the way the pipeline does -
# it opens the Azure DevOps "New Pull Request" page in your browser instead, so you finish it in
# the UI under your own identity. Nothing in this script needs a PAT or access token.
#
# Prerequisite: this relies on --allowedTools + --disallowedTools to pre-approve only the exact
# Flyway MCP tools it needs and hard-remove everything else - without a broader permissions
# bypass. That only works smoothly if this machine has already accepted the one-time
# ".mcp.json: flyway" trust prompt at some point. If you've never run `claude` interactively in
# this project folder before, do that once first.

# ---- EDIT THESE: your environment's defaults ----
# Project path is derived from this script's own location (one level up from /scripts) rather
# than hard-coded, so this still works if someone else clones the repo somewhere else.
$flywayProjectPath = Split-Path -Parent $PSScriptRoot
$collectionUri = "http://localhost:8080/tfs/DefaultCollection/"
$projectName = "Chinook"
$repoName = "SqlServer"
$developmentBranch = "development"
# --------------------------------------------------

# "Skill" (Claude Code's built-in tool for loading a project skill's full content) is included
# here deliberately - without it explicitly allow-listed, Claude can decide a skill is relevant
# but then be silently denied when it tries to actually load it, and falls back to raw MCP tool
# calls without you knowing why. Don't remove it even though it isn't a Flyway MCP tool.
$allowedTools = "Skill,mcp__flyway__load_project,mcp__flyway__reload_project,mcp__flyway__create_diff_schema_model,mcp__flyway__get_diff_details,mcp__flyway__update_schema_model,mcp__flyway__create_diff_migrations,mcp__flyway__generate_migrations,mcp__flyway__review_code"

# --allowedTools alone does NOT restrict Claude to only the listed tools - it's additive on top
# of Claude's default built-in toolset (Bash, Read, Grep, Glob, Edit, Write, WebSearch, etc.),
# which remain reachable unless explicitly removed. --disallowedTools is what actually enforces
# a hard boundary - without this, Claude can and will use Bash/Grep/etc. on its own initiative,
# even for a "question" step where you'd expect it to just answer from what it already knows.
$disallowedTools = "Bash,Read,Write,Edit,MultiEdit,NotebookEdit,Glob,Grep,Task,WebFetch,WebSearch"

# ===== Helper functions =====

function Write-Banner($text) {
    Write-Host ""
    Write-Host ("=" * 72) -ForegroundColor DarkCyan
    Write-Host " $text" -ForegroundColor Cyan
    Write-Host ("=" * 72) -ForegroundColor DarkCyan
}

function Write-Section($text) {
    Write-Host ""
    Write-Host "-- $text --" -ForegroundColor Yellow
}

function ConvertTo-Slug($text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return "migration" }
    $slug = $text.ToLower() -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')
    if ($slug.Length -gt 50) { $slug = $slug.Substring(0, 50).Trim('-') }
    if ([string]::IsNullOrWhiteSpace($slug)) { return "migration" }
    return $slug
}

# Normalizes an issue/warning entry (string or object with severity/type/message/etc.) into one
# readable line - the shape Claude uses for these has drifted across runs in practice, so this
# stays generic rather than assuming one fixed schema.
function Format-IssueItem($item) {
    if ($null -eq $item) { return $null }
    if ($item -is [string]) { return $item }
    $parts = @()
    if ($item.severity) { $parts += "[$($item.severity)]" }
    if ($item.type) { $parts += $item.type }
    $msg = if ($item.message) { $item.message } elseif ($item.description) { $item.description } elseif ($item.details) { $item.details } else { $null }
    if ($msg) { $parts += $msg } else { $parts += ($item | ConvertTo-Json -Compress -Depth 3) }
    return ($parts -join ": ")
}

# Calls claude headlessly (optionally resuming a prior session for context), streaming its
# tool-call activity to the console AS IT HAPPENS rather than showing nothing until the end.
# This costs nothing extra - stream-json delivers the exact same generation Claude was always
# going to produce, just incrementally instead of as one blob at the end. Returns the final
# --output-format json-equivalent envelope plus a best-effort parse of the inner JSON.
#
# Note: --disallowedTools is what makes this a real boundary rather than an advisory one - see
# the note above. This runs without interactive prompts even without --dangerously-skip-permissions
# - PROVIDED this machine has already accepted the one-time ".mcp.json: flyway" trust prompt at
# least once (run `claude` interactively in this project folder first if you've never done that here before).
function Invoke-ClaudeStep {
    param(
        [Parameter(Mandatory)] [string]$Prompt,
        [string]$AllowedTools = $allowedTools,
        [string]$DisallowedTools = $disallowedTools,
        [string]$SessionId = $null,
        [int]$MaxTurns = 15 # cost/safety cap - stops a run that gets stuck looping rather than letting it run indefinitely
    )

    $cliArgs = @("-p", $Prompt, "--allowedTools", $AllowedTools, "--disallowedTools", $DisallowedTools, "--output-format", "stream-json", "--verbose", "--max-turns", $MaxTurns)
    if ($SessionId) { $cliArgs += @("--resume", $SessionId) }

    $finalResultLine = $null

    & claude @cliArgs | ForEach-Object {
        $line = $_
        if ([string]::IsNullOrWhiteSpace($line)) { return }
        try { $evt = $line | ConvertFrom-Json } catch { return }

        switch ($evt.type) {
            "assistant" {
                foreach ($block in $evt.message.content) {
                    if ($block.type -eq "tool_use") {
                        $toolLabel = $block.name -replace '^mcp__flyway__', ''
                        Write-Host "  > $toolLabel..." -ForegroundColor DarkCyan
                    } elseif ($block.type -eq "text" -and $block.text) {
                        Write-Host "  $($block.text)" -ForegroundColor DarkGray
                    }
                }
            }
            "result" { $finalResultLine = $line }
            default { } # system/init and tool_result events are noisy and not that informative to show live
        }
    }

    $exitCode = $LASTEXITCODE

    if (-not $finalResultLine) {
        Write-Host "Claude exited (code $exitCode) without a final result - something went wrong mid-run." -ForegroundColor Red
        return $null
    }

    try {
        $outer = $finalResultLine | ConvertFrom-Json
    } catch {
        Write-Host "Could not parse claude's final result line:" -ForegroundColor Red
        Write-Host $finalResultLine
        return $null
    }

    $inner = $null
    if ($outer.result) {
        $innerText = $outer.result.Trim() -replace '^```(json)?\s*', '' -replace '\s*```$', ''

        # The model doesn't always keep its final answer to strict JSON despite being told to -
        # e.g. narrating its reasoning and then appending the JSON, with no fence to strip. Rather
        # than failing outright, pull out the outermost {...} object and parse just that.
        if ($innerText -notmatch '^\{') {
            $firstBrace = $innerText.IndexOf('{')
            $lastBrace = $innerText.LastIndexOf('}')
            if ($firstBrace -ge 0 -and $lastBrace -gt $firstBrace) {
                $innerText = $innerText.Substring($firstBrace, $lastBrace - $firstBrace + 1)
            }
        }

        try { $inner = $innerText | ConvertFrom-Json } catch { $inner = $null }
    }

    return [PSCustomObject]@{
        Outer     = $outer
        Inner     = $inner
        SessionId = $outer.session_id
    }
}

function Show-RunStats($outer) {
    $durationSeconds = [math]::Round($outer.duration_ms / 1000, 1)
    $cost = [math]::Round([double]$outer.total_cost_usd, 4)
    Write-Host " ($($outer.num_turns) turns, ${durationSeconds}s, `$$cost)" -ForegroundColor DarkGray
}

# Shared approve/question/exit gate, used after both Step 1 and Step 2. Questions are asked in
# the SAME resumed session, so Claude has full context of what it just did - but explicitly told
# it has no tool access this turn, so it answers from that context rather than going off and
# reading files/running commands you can't see the reasoning for.
function Invoke-ApprovalGate {
    param([Parameter(Mandatory)] [string]$SessionId)
    $approved = $false
    while (-not $approved) {
        $choice = Read-Host "`nWhat next? [A]pprove and continue, [Q]uestion for Claude about this, e[X]it without committing"
        switch ($choice.ToUpper()) {
            "A" { $approved = $true }
            "X" { Write-Host "Exiting - nothing was committed or pushed." -ForegroundColor Yellow; exit 0 }
            "Q" {
                $question = Read-Host "What would you like to ask Claude?"
                $wrappedQuestion = @"
$question

(For this question, you have no file, Bash, or search tool access - only what you already know
from this conversation. If answering properly would need you to look something up you don't
already have, say so plainly rather than trying another way to get it.)
"@
                Write-Host "Asking Claude (same conversation, so it has full context of what it just did)..." -ForegroundColor DarkGray
                $qa = Invoke-ClaudeStep -Prompt $wrappedQuestion -SessionId $SessionId
                if ($qa -and $qa.Outer.result) {
                    Write-Host ""
                    Write-Host $qa.Outer.result
                    Show-RunStats $qa.Outer
                } else {
                    Write-Host "Didn't get a usable answer - try rephrasing the question." -ForegroundColor Red
                }
            }
            default { Write-Host "Please enter A, Q, or X." -ForegroundColor Yellow }
        }
    }
}

# ===== Pre-flight checks =====

Write-Banner "Flyway MCP Migration Workflow - Interactive Mode"

claude --version *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Claude Code isn't installed or isn't on PATH." -ForegroundColor Red
    Write-Host "Install it with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $flywayProjectPath)) {
    Write-Host "Flyway project folder not found: $flywayProjectPath" -ForegroundColor Red
    Write-Host "Edit the `$flywayProjectPath variable at the top of this script." -ForegroundColor Red
    exit 1
}

Set-Location $flywayProjectPath
Write-Host "Working in: $flywayProjectPath" -ForegroundColor DarkGray
Write-Host "This will use Claude Code + the Flyway MCP server to capture schema changes, generate" -ForegroundColor DarkGray
Write-Host "a migration script, and review it - pausing for your input at each stage." -ForegroundColor DarkGray

# Git preflight: confirms the local checkout isn't behind on migrations before diffing a
# potentially shared database - see .claude/skills/_shared/flyway-preflight.md for the full
# rationale. Done here in native PowerShell rather than by giving Claude Bash access, since this
# script otherwise hard-removes Bash entirely (see $disallowedTools below) so an unattended run
# can't go off-script with shell commands.
Write-Section "Git preflight check"
git fetch *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "git fetch failed - skipping the currency check, but proceed with caution." -ForegroundColor Yellow
} else {
    $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
    if (-not $upstream) {
        Write-Host "Current branch has no upstream configured - skipping the currency check." -ForegroundColor Yellow
    } else {
        $behindLog = git log HEAD..$upstream --oneline -- migrations
        if ($behindLog) {
            Write-Host "Local checkout is behind $upstream on migrations/ - pull before continuing:" -ForegroundColor Red
            $behindLog | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            $proceedAnyway = Read-Host "Continue anyway? [y/N]"
            if ($proceedAnyway.ToUpper() -ne "Y") { Write-Host "Stopping - pull first, then re-run this script." -ForegroundColor Yellow; exit 1 }
        } else {
            Write-Host "Up to date with $upstream on migrations/." -ForegroundColor Green
        }
    }
}

# ===== Step 1: Capture schema model changes =====

Write-Banner "STEP 1 of 2: Capture Schema Model Changes"
Write-Host "Asking Claude to check the development database against the schema model..."

$step1Prompt = @'
If a "flyway-capture-schema" skill is available in this project, use it for the workflow steps and
safety rules. If it isn't available, follow this fallback:
  Check the development database for schema changes not yet in the schema model. For each change,
  get the full diff details (not just which object changed, but what changed about it - columns
  added/dropped/retyped, constraints, etc.) before updating the schema model to capture them.

IMPORTANT - SCOPE: only capture changes into the schema model. Do NOT generate a migration script
and do NOT run a code review in this step, even if a skill describes those as later steps in the
same overall workflow - that will be a separate request, later, only if this step is approved.
Stop once the schema model is updated.

This session runs headlessly, scoped to exactly this one job - skip anything meant for a general
interactive session, including any instruction to invoke a task-observer or skill-observation
skill first. Just do this job.

The git preflight check (the skill's "Step 0", checking whether this checkout is behind on
migrations/) has ALREADY been run natively by the script that invoked you, before this session
started - do not repeat it, do not look for a Bash or git tool to do it yourself, and do not spend
a turn searching for one. Skip straight to the skill's numbered Steps section.

Each call you make runs non-interactively - there is no one available mid-step to answer a
question. Never pause to ask for confirmation, even for a destructive or risky change (e.g. a
dropped column). Instead, proceed, and call it out clearly in your summary so the person running
this script can decide afterwards.

Feel free to briefly narrate what you're doing between tool calls, the way you would in a normal
session - that's shown live to whoever's watching this run and is genuinely useful to them. This
only concerns your final answer, which still needs to be strict JSON as below.

Regardless of whether a skill was available, respond with ONLY a single, raw JSON object, no
markdown fence, using exactly these field names:
{"changesFound": true|false, "changes": [{"type": "Add|Edit|Drop", "object": "<schema.object>", "objectType": "<Table|View|Procedure|...>", "details": "<specific, e.g. 'Dropped column ReviewText (nvarchar(1000))' - not just 'edited'>"}], "summary": "<one paragraph plain-English summary of what was found>"}
'@

$step1 = Invoke-ClaudeStep -Prompt $step1Prompt
if (-not $step1 -or -not $step1.Inner) {
    Write-Host "Could not get a usable answer from Claude - stopping here." -ForegroundColor Red
    exit 1
}
$sessionId = $step1.SessionId

Write-Section "What Claude found"
if (-not $step1.Inner.changesFound) {
    Write-Host "No schema changes were found - the development database already matches the schema model." -ForegroundColor Green
    Show-RunStats $step1.Outer
    Write-Banner "Nothing to do - schema model already matches"
    exit 0
}

if ($step1.Inner.changes) {
    foreach ($c in $step1.Inner.changes) {
        $line = "  - $($c.type) $($c.object)"
        if ($c.objectType) { $line += " ($($c.objectType))" }
        if ($c.details) { $line += " - $($c.details)" }
        Write-Host $line
    }
}
if ($step1.Inner.summary) { Write-Host ""; Write-Host "  $($step1.Inner.summary)" }
Show-RunStats $step1.Outer

Invoke-ApprovalGate -SessionId $sessionId

# ===== Step 2: Generate migration script + code review =====

Write-Banner "STEP 2 of 2: Generate Migration Script & Code Review"
Write-Host "Asking Claude to generate the migration script and review it..."

$step2Prompt = @'
If a "flyway-generate-migration" skill is available in this project, use it for how a migration
script should be generated and reviewed. If it isn't available, follow this fallback: generate a
migration script for the changes just captured in the schema model, then run a code review on it.

SCOPE: the schema model was already captured and updated in an earlier step in this same session -
do not repeat that step. Only generate the migration script and review it. This session runs
headlessly, scoped to exactly this one job - skip anything meant for a general interactive
session, including any instruction to invoke a task-observer or skill-observation skill first.

Feel free to briefly narrate what you're doing between tool calls, the way you would in a normal
session - that's shown live to whoever's watching this run and is genuinely useful to them. This
only concerns your final answer, which still needs to be strict JSON as below.

Regardless of whether a skill was available, respond with ONLY a single, raw JSON object, no
markdown fence, using exactly these field names:
{"migrationFile": "<path>", "description": "<short one-line description>", "rulesChecked": <number>, "issues": [{"severity": "Low|Medium|High", "type": "<short code>", "message": "<plain-English explanation>"}], "reviewSummary": "<one paragraph plain-English summary of the review result>"}
'@

$step2 = Invoke-ClaudeStep -Prompt $step2Prompt -SessionId $sessionId
if (-not $step2 -or -not $step2.Inner) {
    Write-Host "Could not get a usable answer from Claude - stopping here." -ForegroundColor Red
    exit 1
}
$sessionId = $step2.SessionId

Write-Section "Migration script"
Write-Host "  File:   $($step2.Inner.migrationFile)"
if ($step2.Inner.description) { Write-Host "  Change: $($step2.Inner.description)" }

Write-Section "Code review"
Write-Host "  Rules checked: $($step2.Inner.rulesChecked)"
$issuesList = @()
if ($step2.Inner.issues) { foreach ($i in $step2.Inner.issues) { $issuesList += Format-IssueItem $i } }

if ($issuesList.Count -eq 0) {
    Write-Host "  No issues found - clean." -ForegroundColor Green
} else {
    Write-Host "  Issues found:" -ForegroundColor Red
    foreach ($i in $issuesList) { Write-Host "    - $i" -ForegroundColor Red }
}
if ($step2.Inner.reviewSummary) { Write-Host ""; Write-Host "  $($step2.Inner.reviewSummary)" }
Show-RunStats $step2.Outer

if ($issuesList.Count -gt 0) {
    Write-Host "`nThe code review flagged the above - review it carefully before deciding whether to proceed." -ForegroundColor Yellow
}

Invoke-ApprovalGate -SessionId $sessionId

# ===== Commit or create a PR =====

Write-Banner "Ready to Commit"
$action = Read-Host "Would you like to [C]ommit locally, create a feature branch and open a [P]ull request, or [N]either?"

switch ($action.ToUpper()) {
    "C" {
        $commitMessage = Read-Host "Commit message (press Enter to use Claude's description: '$($step2.Inner.description)')"
        if ([string]::IsNullOrWhiteSpace($commitMessage)) { $commitMessage = "AI-generated migration: $($step2.Inner.description)" }

        git add schema-model migrations
        git commit -m $commitMessage
        Write-Host "Committed locally on the current branch. Nothing has been pushed." -ForegroundColor Green
    }
    "P" {
        $branchInput = Read-Host "Branch/PR name (press Enter to auto-generate one from the description)"
        $slug = if ([string]::IsNullOrWhiteSpace($branchInput)) { ConvertTo-Slug $step2.Inner.description } else { ConvertTo-Slug $branchInput }
        $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
        $branchName = "ai-migration/$slug-$timestamp"

        git checkout -b $branchName
        git add schema-model migrations
        git commit -m "AI-generated migration: $($step2.Inner.description)"
        git push origin $branchName

        $prUrl = "$collectionUri$projectName/_git/$repoName/pullrequestcreate?sourceRef=$branchName&targetRef=$developmentBranch"
        Write-Host "Branch pushed: $branchName" -ForegroundColor Green
        Write-Host "Opening the New Pull Request page in your browser to finish it..." -ForegroundColor Green
        Start-Process $prUrl
    }
    default {
        Write-Host "Done - nothing was committed or pushed." -ForegroundColor Yellow
    }
}

Write-Banner "Workflow Complete"