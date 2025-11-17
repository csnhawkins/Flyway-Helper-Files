# ===========================
# Script Name: 00_Flyway_Migrations_Migrate.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the MIGRATE verb to deploy pending changes to SHADOW environment to validate
# ===========================

# Variables #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB" 
$TARGET_ENVIRONMENT = "shadow"
$TARGET_ENVIRONMENT_USERNAME = ""
$TARGET_ENVIRONMENT_PASSWORD = ""

# Calculate the differences between two entities (Databases/Folders & More) #
flyway migrate info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY"