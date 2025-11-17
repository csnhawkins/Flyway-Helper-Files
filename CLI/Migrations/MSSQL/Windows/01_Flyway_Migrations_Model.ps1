# ===========================
# Script Name: 00_Flyway_Migrations_Model.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the Model verb to capture artifact differences to project Schema Model
# ===========================


# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB" 

flyway model `
"-model.artifactFilename=$ARTIFACT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"