@echo off
REM ===========================
REM Script Name: 04_Flyway_Migrations_Migrate.bat
REM Version: 1.0.1
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-12-17
REM Description: Flyway Migrations Based - Use the MIGRATE verb to deploy pending changes to SHADOW environment to validate
REM ===========================

REM Variables - Customize these for your environment
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\Chinook\SqlServer"
set "TARGET_ENVIRONMENT=shadow"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM Calculate the differences between two entities (Databases/Folders & More)
flyway migrate info ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause