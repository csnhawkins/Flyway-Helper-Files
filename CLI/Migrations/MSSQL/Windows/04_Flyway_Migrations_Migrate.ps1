# ===========================
# Script Name: 04_Flyway_Migrations_Migrate.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the MIGRATE verb to deploy pending changes to SHADOW environment to validate
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway migrations-based project root
$TARGET_ENVIRONMENT = "test"  # Target database environment name
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)
$SAVE_SNAPSHOT = "true" # Optional - Save schema snapshot in target environment

# Calculate the differences between two entities (Databases/Folders & More) #
flyway migrate info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-migrate.saveSnapshot=$SAVE_SNAPSHOT" `
-workingDirectory="$WORKING_DIRECTORY"