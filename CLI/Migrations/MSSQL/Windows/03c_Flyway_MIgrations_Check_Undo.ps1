# ===========================
# Script Name: 03c_Flyway_Migrations_Check_Undo.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2026-06-19
# Description: Flyway Migrations Based - Create a dryrun and check report for rollback scenarios
# ===========================

# Variables - Customize these for your environment #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Chinook\SqlServer"  # Path to Flyway migrations-based project root
$TARGET_ENVIRONMENT = "Test"  # Target database environment name for undo operation
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)
$REPORT_ENVIRONMENT = "shadow"  # Sandbox environment name
$REPORT_ENVIRONMENT_USERNAME = ""  # Sandbox database username (leave empty for flyway.toml)
$REPORT_ENVIRONMENT_PASSWORD = ""  # Sandbox database password (use env variables in 
$CHERRY_PICK = "003" # Provide the comma separated version numbers
$UNDO_SCRIPT_NAME = "MyUndoScript.sql"
$REPORT_FILENAME = "Flyway-Check-Undo.html"  # Output deployment script name

# Calculate the differences between two entities (Databases/Folders & More) #
flyway undo info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY" `
-cherryPick="$CHERRY_PICK" `
-dryRunOutput="$UNDO_SCRIPT_NAME"

flyway check -changes -code `
"-check.buildEnvironment=$REPORT_ENVIRONMENT" `
"-environments.$REPORT_ENVIRONMENT.user=$REPORT_ENVIRONMENT_USERNAME" `
"-environments.$REPORT_ENVIRONMENT.password=$REPORT_ENVIRONMENT_PASSWORD" `
"-environment=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-check.scope=script" `
"-check.scriptFilename=$UNDO_SCRIPT_NAME" `
-configFiles="$WORKING_DIRECTORY\flyway.toml" `
-workingDirectory="$WORKING_DIRECTORY" `
"-reportFilename=$WORKING_DIRECTORY\Artifact\$REPORT_FILENAME"
