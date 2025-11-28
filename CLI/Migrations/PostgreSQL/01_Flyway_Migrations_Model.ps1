# ===========================
# Script Name: 01_Flyway_Migrations_Model.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the MODEL verb to generate a model from a database
# ===========================

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"  # Output file for model artifact
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila"  # Path to Flyway migrations-based project root 

flyway model `
"-model.artifactFilename=$ARTIFACT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"