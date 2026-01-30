# ===========================
# Script Name: 100_Iterate_Per.ps1
# Version: 2.0.0
# Description: Flyway Diff & Model with Interactive Change Selection
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Chinook\SqlServer"
$ARTIFACT_FILENAME = "$WORKING_DIRECTORY\Artifact\Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"
$SOURCE_ENVIRONMENT = "development"
$SOURCE_ENVIRONMENT_USERNAME = ""
$SOURCE_ENVIRONMENT_PASSWORD = ""
$TARGET_ENVIRONMENT = "schemaModel"

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Flyway Diff & Model with Change Selection" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# ===========================
# STEP 1: DIFF
# ===========================
Write-Host "Step 1: Running Flyway Diff..." -ForegroundColor Green

flyway diff `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-environments.$SOURCE_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" `
"-environments.$SOURCE_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flyway Diff failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Diff completed successfully." -ForegroundColor Green
Write-Host ""

# ===========================
# STEP 2: CHANGE SELECTION
# ===========================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CHANGE SELECTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Extract artifact to find JSON
$extractPath = "$env:TEMP\Flyway-Diff-Extract-$(Get-Date -f yyyyMMddHHmmss)"
$null = New-Item -ItemType Directory -Path $extractPath -Force

try {
    # Use the artifact path directly (already expanded)
    if (-not (Test-Path $ARTIFACT_FILENAME)) {
        Write-Host "ERROR: Artifact file not found at '$ARTIFACT_FILENAME'" -ForegroundColor Red
        exit 1
    }
    
    Expand-Archive -Path $ARTIFACT_FILENAME -DestinationPath $extractPath -Force
    
    # Find the JSON file
    $jsonFiles = Get-ChildItem -Path $extractPath -Filter "*.json" -Recurse
    
    Write-Host "DEBUG: Found $($jsonFiles.Count) JSON file(s) in artifact:" -ForegroundColor DarkGray
    foreach ($file in $jsonFiles) {
        Write-Host "  - $($file.Name) at $($file.FullName)" -ForegroundColor DarkGray
    }
    
    $jsonFile = $jsonFiles | Select-Object -First 1
    
    if (-not $jsonFile) {
        Write-Host "ERROR: Could not find JSON file in artifact" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Using JSON file: $($jsonFile.Name)" -ForegroundColor DarkGray
    
    # Parse the JSON
    $diffData = Get-Content -LiteralPath $jsonFile.FullName -Raw | ConvertFrom-Json
    
    # DEBUG: Show JSON structure
    Write-Host "DEBUG: JSON properties: $($diffData.PSObject.Properties.Name -join ', ')" -ForegroundColor DarkGray
    
    # DEBUG: Show comparisonResult structure
    if ($diffData.comparisonResult) {
        Write-Host "DEBUG: comparisonResult is an array with $($diffData.comparisonResult.Count) items" -ForegroundColor DarkGray
        if ($diffData.comparisonResult.Count -gt 0) {
            Write-Host "DEBUG: First item type: $($diffData.comparisonResult[0].GetType().Name)" -ForegroundColor DarkGray
            Write-Host "DEBUG: First item properties: $($diffData.comparisonResult[0].PSObject.Properties.Name -join ', ')" -ForegroundColor DarkGray
        }
    }
    
    # comparisonResult IS the array of differences
    $differences = $null
    if ($diffData.comparisonResult -and $diffData.comparisonResult.Count -gt 0) {
        $differences = $diffData.comparisonResult
        Write-Host "DEBUG: Using comparisonResult as differences array: $($differences.Count) items" -ForegroundColor DarkGray
    } elseif ($diffData.differences) {
        $differences = $diffData.differences
        Write-Host "DEBUG: Using differences property: $($differences.Count) items" -ForegroundColor DarkGray
    } else {
        Write-Host "DEBUG: No differences found in JSON structure" -ForegroundColor DarkGray
    }
    Write-Host "" 
    
    if ($differences -and $differences.Count -gt 0) {
        Write-Host "Found $($differences.Count) difference(s):" -ForegroundColor Green
        Write-Host ""
        
        # Create mapping and display table
        $changeMapping = @{}
        $displayData = @()
        
        for ($i = 0; $i -lt $differences.Count; $i++) {
            $diff = $differences[$i]
            
            # DEBUG: Show first difference structure
            if ($i -eq 0) {
                Write-Host "DEBUG: First difference properties: $($diff.PSObject.Properties.Name -join ', ')" -ForegroundColor DarkGray
                Write-Host "DEBUG: First difference raw: $($diff | ConvertTo-Json -Depth 2)" -ForegroundColor DarkGray
            }
            
            $simpleId = "{0:D3}" -f ($i + 1)
            $changeMapping[$simpleId] = $diff.id
            
            # Try different property paths
            $fromName = if ($diff.from -and $diff.from.name) { 
                $diff.from.name 
            } elseif ($diff.name) { 
                $diff.name 
            } else { 
                "N/A" 
            }
            
            $fromSchema = if ($diff.from -and $diff.from.schema) { 
                $diff.from.schema 
            } elseif ($diff.schema) { 
                $diff.schema 
            } else { 
                "N/A" 
            }
            
            $diffType = if ($diff.differenceType) { 
                $diff.differenceType 
            } elseif ($diff.type) { 
                $diff.type 
            } else { 
                "N/A" 
            }
            
            $objType = if ($diff.objectType) { 
                $diff.objectType 
            } else { 
                "N/A" 
            }
            
            $displayData += [PSCustomObject]@{
                ID = $simpleId
                Type = $diffType
                ObjectType = $objType
                Schema = $fromSchema
                Name = $fromName
            }
        }
        
        # Display as table
        $displayData | Format-Table -AutoSize | Out-String | Write-Host
        
        Write-Host "Select which changes to include in the Model step." -ForegroundColor Cyan
        Write-Host "Examples: '001,003,005' or '001-005' or 'ALL' (default=ALL)" -ForegroundColor DarkGray
        Write-Host ""
        
        $selection = Read-Host "Enter change IDs"
        
        if ([string]::IsNullOrWhiteSpace($selection) -or $selection.ToUpper() -eq "ALL") {
            # Select all
            $selectedIds = $changeMapping.Values
            Write-Host "Selected: ALL changes" -ForegroundColor Green
        }
        else {
            # Parse selection
            $selectedSimpleIds = @()
            
            # Handle ranges (e.g., 001-005) and individual IDs (001,003,005)
            $parts = $selection -split ','
            foreach ($part in $parts) {
                $part = $part.Trim()
                if ($part -match '^(\d+)-(\d+)$') {
                    # Range
                    $start = [int]$matches[1]
                    $end = [int]$matches[2]
                    for ($i = $start; $i -le $end; $i++) {
                        $selectedSimpleIds += "{0:D3}" -f $i
                    }
                }
                elseif ($part -match '^\d+$') {
                    # Individual ID
                    $selectedSimpleIds += "{0:D3}" -f ([int]$part)
                }
            }
            
            # Map to real IDs
            $selectedIds = @()
            foreach ($simpleId in $selectedSimpleIds) {
                if ($changeMapping.ContainsKey($simpleId)) {
                    $selectedIds += $changeMapping[$simpleId]
                }
                else {
                    Write-Host "WARNING: ID '$simpleId' not found, skipping" -ForegroundColor Yellow
                }
            }
            
            if ($selectedIds.Count -eq 0) {
                Write-Host "ERROR: No valid changes selected" -ForegroundColor Red
                exit 1
            }
            
            Write-Host "Selected: $($selectedIds.Count) change(s)" -ForegroundColor Green
        }
        
        $selectedChangeIds = ($selectedIds -join ',')
        Write-Host ""
    }
    else {
        Write-Host "No differences found in artifact." -ForegroundColor Yellow
        $selectedChangeIds = $null
    }
}
catch {
    Write-Host "ERROR parsing diff artifact: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Cleanup temp extraction
    if (Test-Path $extractPath) {
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ===========================
# STEP 3: MODEL
# ===========================
Write-Host "Step 2: Running Flyway Model with selected changes..." -ForegroundColor Green

if ($selectedChangeIds) {
    Write-Host "Applying changes: $selectedChangeIds" -ForegroundColor DarkGray
    
    flyway model `
    "-model.artifactFilename=$ARTIFACT_FILENAME" `
    "-model.changes=$selectedChangeIds" `
    -workingDirectory="$WORKING_DIRECTORY"
}
else {
    flyway model `
    "-model.artifactFilename=$ARTIFACT_FILENAME" `
    -workingDirectory="$WORKING_DIRECTORY"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flyway Model failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Model completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Workflow Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green