# ===========================
# Script Name: 00_Flyway_State_Model.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Model verb to capture artifact differences to project Schema Model
# ===========================

# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State" 

flyway model `
"-model.artifactFilename=$ARTIFACT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"