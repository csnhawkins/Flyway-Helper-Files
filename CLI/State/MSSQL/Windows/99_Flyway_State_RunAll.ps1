param(
    [switch]$All  # Optional: run all steps without prompts
)

Write-Host "Starting Flyway State-Based Workflow - Run All..." -ForegroundColor Green

# Define steps with descriptions
$steps = @(
    @{ Name = '00_Flyway_State_Diff.ps1';     Description = 'Compare current state with desired model and create artifact' },
    @{ Name = '01_Flyway_State_Model.ps1';    Description = 'Update or validate schema model from artifact' },
    @{ Name = '02_Flyway_State_Prepare.ps1';  Description = 'Generate deployment and undo scripts' },
    @{ Name = '03a_Flyway_State_Snapshot.ps1'; Description = 'Create schema snapshot for point-in-time recovery' },
    @{ Name = '03b_Flyway_State_Check.ps1';    Description = 'Analyze changes, detect drift, and generate compliance reports' },
    @{ Name = '04_Flyway_State_Deploy.ps1';   Description = 'Execute deployment script against target with optional snapshot' }
)

# Determine base folder
if ($PSScriptRoot) {
    $basePath = $PSScriptRoot
} else {
    Write-Host "Cannot determine script location (likely running in VS Code selection mode)." -ForegroundColor Yellow
    $basePath = Read-Host "Please enter the full path to the folder containing the step scripts"
}

# Validate base folder
if (-not (Test-Path -LiteralPath $basePath)) {
    Write-Host "ERROR: The path '$basePath' does not exist." -ForegroundColor Red
    exit 1
}

Write-Host ("Flyway State-Based Deployment") -ForegroundColor Magenta
Write-Host ("Script folder: {0}" -f $basePath) -ForegroundColor DarkGray

# Check that all steps exist before starting
foreach ($step in $steps) {
    $filePath = Join-Path -Path $basePath -ChildPath $step.Name
    if (-not (Test-Path -LiteralPath $filePath)) {
        Write-Host "ERROR: Missing step script '$($step.Name)' in '$basePath'." -ForegroundColor Red
        exit 1
    }
}

# Run steps
foreach ($step in $steps) {
    $stepPath = Join-Path -Path $basePath -ChildPath $step.Name

    if (-not $All) {
        Write-Host ""
        Write-Host "Step: $($step.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($step.Description)" -ForegroundColor DarkGray
        $resp = Read-Host "Run this step? (Y/N, default=Y)"

        # Default to Yes if Enter pressed; only skip on explicit 'N' or 'No'
        if (-not [string]::IsNullOrWhiteSpace($resp) -and $resp -notmatch '^(?i:y|yes)$') {
            Write-Host "Skipping step: $($step.Name)" -ForegroundColor Yellow
            continue
        }
    }

    Write-Host "Running step: $($step.Name) - $($step.Description)" -ForegroundColor Green

    # Execute step and determine outcome robustly
    $stepSucceeded = $true
    $exitCode = 0

    try {
        # Reset LASTEXITCODE so we don't carry over stale non-zero values
        $LASTEXITCODE = 0

        & $stepPath

        # Capture any exit code set by the step
        if ($LASTEXITCODE -ne $null) {
            $exitCode = [int]$LASTEXITCODE
        }

        # If last command failed, mark as failure
        if (-not $?) {
            $stepSucceeded = $false
            if ($exitCode -eq 0) { $exitCode = 1 }
        }

        # Non-zero exit code indicates failure too
        if ($exitCode -ne 0) {
            $stepSucceeded = $false
        }
    }
    catch {
        $stepSucceeded = $false
        if ($exitCode -eq 0) { $exitCode = 1 }
        Write-Host ("Exception: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    if (-not $stepSucceeded) {
        Write-Host "ERROR: Step $($step.Name) failed. ExitCode=$exitCode" -ForegroundColor Red
        exit $exitCode
    }

    Write-Host "Step $($step.Name) completed." -ForegroundColor Green
}

Write-Host "`nFlyway State-Based Deployment Complete!" -ForegroundColor Green
