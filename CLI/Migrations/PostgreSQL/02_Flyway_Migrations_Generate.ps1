# ===========================
# Script Name: 02_Flyway_Migrations_Generate.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the GENERATE verb to create migration scripts
# ===========================

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"  # Input artifact file from diff operation
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila"  # Path to Flyway migrations-based project root
$SOURCE_ENVIRONMENT = "schemaModel"
$TARGET_ENVIRONMENT = "migrations"
$BUILD_ENVIRONMENT = "shadow"
$BUILD_ENVIRONMENT_USERNAME = "postgres"
$BUILD_ENVIRONMENT_PASSWORD = Read-Host -Prompt "Enter password for database user" -AsSecureString | ConvertFrom-SecureString -AsPlainText
$FLYWAY_VERSION_DESCRIPTION = "FlywayCLI_AutomatedMigrationScript"

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