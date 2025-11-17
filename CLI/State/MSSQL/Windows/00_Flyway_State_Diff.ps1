# ===========================
# Script Name: 00_Flyway_State_Diff.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the DIFF verb to create an artifact between two environments
# ===========================

# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State" 
$SOURCE_ENVIRONMENT = "development" # Source Comparison Environment - Defaulting to Development
$SOURCE_ENVIRONMENT_USERNAME = ""
$SOURCE_ENVIRONMENT_PASSWORD = ""
$TARGET_ENVIRONMENT = "schemaModel" # Target Comparison Environment - Defaulting to the projects Schema Model

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""