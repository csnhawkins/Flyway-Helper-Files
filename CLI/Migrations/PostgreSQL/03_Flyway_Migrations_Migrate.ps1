# ===========================
# Script Name: 03_Flyway_Migrations_Migrate.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the MIGRATE verb to apply migration scripts to database
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila"  # Path to Flyway migrations-based project root
$TARGET_ENVIRONMENT = "prod"  # Target database environment to migrate
$TARGET_ENVIRONMENT_USERNAME = "postgres"  # Target database username
$TARGET_ENVIRONMENT_PASSWORD = Read-Host -Prompt "Enter password for $TARGET_ENVIRONMENT_USERNAME"  # Prompt for password

# Calculate the differences between two entities (Databases/Folders & More) #
flyway migrate info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY"