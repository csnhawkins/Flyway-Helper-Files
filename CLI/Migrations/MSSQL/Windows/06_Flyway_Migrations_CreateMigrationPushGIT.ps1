# ===========================
# Script Name: 06_Flyway_Migrations_CreateMigrationPushGIT.ps1
# Version: 1.0.0
# Author: Marko Coha (Redgate Software Ltd)
# Last Updated: 2025-11-28
# Description: Flyway Migrations Based - Use multiple verbs to create a migration script and push to GIT
# ===========================

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"  # Output file for comparison results
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway project root
$SOURCE_ENVIRONMENT = "development"  # Source database environment name
$SOURCE_ENVIRONMENT_USERNAME = ""  # Source database username (leave empty for flyway.toml)
$SOURCE_ENVIRONMENT_PASSWORD = ""  # Source database password (use env variables in production)
$TARGET_ENVIRONMENT = "schemaModel"  # Target environment name (schemaModel for migrations)

# Calculate the differences between two entities (Dev Database & Schema Model) #

flyway diff `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-environments.$SOURCE_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" `
"-environments.$SOURCE_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""

# Save differences into Schema Model #

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"  # Input artifact file from diff operation
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway project root 

flyway model `
"-model.artifactFilename=$ARTIFACT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"

# ===========================
# Create Migration Script from Differences
# ===========================

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Migrations.differences-$(get-date -f yyyyMMdd).zip"  # Output file for generated migrations
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway project root
$SOURCE_ENVIRONMENT = "schemaModel"  # Source environment name (desired state)
$TARGET_ENVIRONMENT = "migrations"  # Target environment name (existing migrations)
$BUILD_ENVIRONMENT = "shadow"  # Build database environment name for validation
$BUILD_ENVIRONMENT_USERNAME = ""  # Build database username (leave empty for flyway.toml)
$BUILD_ENVIRONMENT_PASSWORD = ""  # Build database password (use env variables in production)
$FLYWAY_VERSION_DESCRIPTION = "FlywayCLI_AutomatedMigrationScript"  # Description for migration script filename

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff generate `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-diff.buildEnvironment=$BUILD_ENVIRONMENT" `
"-environments.$BUILD_ENVIRONMENT.user=$BUILD_ENVIRONMENT_USERNAME" `
"-environments.$BUILD_ENVIRONMENT.password=$BUILD_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
"-generate.artifactFilename=$ARTIFACT_FILENAME" `
"-generate.description=$FLYWAY_VERSION_DESCRIPTION" `
"-generate.location=$WORKING_DIRECTORY\migrations" `
"-generate.types=versioned,undo" `
"-generate.addTimestamp=true" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""

# ===========================
# Validate Migrtion Script Against Shadow Database
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway project root
$TARGET_ENVIRONMENT = "shadow"  # Target database environment name
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)

# Calculate the differences between two entities (Databases/Folders & More) #
flyway migrate info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY"
# Navigate to this script directory (optional)
Set-Location $PSScriptRoot

# Check if there are changes to commit
$status = git status --porcelain

if (-not $status) {
    Write-Host "No changes to commit. Exiting."
    exit
}

# Generate automatic commit message
$timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$commitMessage = "Auto-commit from script at $timestamp"

# Stage all changes
git add -A

# Create commit
git commit -m "$commitMessage"

# Push to origin/main
git push origin development

Write-Host "Auto-commit and push completed." -ForegroundColor Green