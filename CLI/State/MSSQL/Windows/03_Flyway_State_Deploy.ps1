# ===========================
# Script Name: 01_Flyway_State_Deploy.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
# ===========================

# Variables #
$SCRIPT_FILENAME = "%temp%\Artifacts\D_Flyway-Dryrun_Deployment_Script-$(get-date -f yyyyMMdd).sql"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State" 
$TARGET_ENVIRONMENT = "Test"
$TARGET_ENVIRONMENT_USERNAME = ""
$TARGET_ENVIRONMENT_PASSWORD = ""

# Deploy Script to target #
flyway deploy `
"-environment=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-deploy.scriptFilename=$SCRIPT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"