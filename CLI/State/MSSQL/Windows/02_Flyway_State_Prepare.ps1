# ===========================
# Script Name: 01_Flyway_State_Prepare.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the PREPARE verb to create deployment script between two environments (By default - Changes in the Schema Model not in the Test environment)
# ===========================

# Variables #
$SCRIPT_FILENAME = "Flyway-Dryrun_Deployment_Script-$(get-date -f yyyyMMdd).sql"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State" 
$SOURCE_ENVIRONMENT = "schemaModel"
$TARGET_ENVIRONMENT = "Test"
$TARGET_ENVIRONMENT_USERNAME = ""
$TARGET_ENVIRONMENT_PASSWORD = ""

# Prepare Script for Deployment #
flyway prepare `
"-prepare.source=$SOURCE_ENVIRONMENT" `
"-prepare.target=$TARGET_ENVIRONMENT" `
"-prepare.types=deploy,undo" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-prepare.scriptFilename=%temp%\Artifacts\D_$SCRIPT_FILENAME" `
"-prepare.undoFilename=%temp%\Artifacts\U_$SCRIPT_FILENAME" `
"-prepare.force=true" `
-configFiles="$WORKING_DIRECTORY\flyway.toml" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model"