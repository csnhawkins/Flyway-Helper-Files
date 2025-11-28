# ===========================
# Script Name: 04_Flyway_Migrations_Undo.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the UNDO verb to rollback migration scripts from database
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila"  # Path to Flyway migrations-based project root
$TARGET_ENVIRONMENT = "prod"  # Target database environment to rollback
$TARGET_ENVIRONMENT_USERNAME = "postgres"  # Target database username
$TARGET_ENVIRONMENT_PASSWORD = "Redg@te1"  # Target database password (use env variables in production)

# Calculate the differences between two entities (Databases/Folders & More) #
flyway undo info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY"