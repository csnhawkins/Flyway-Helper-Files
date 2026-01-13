@echo off
REM ===========================
REM Script Name: 05_Flyway_Migrations_Undo.bat
REM Version: 1.0.1
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-12-17
REM Description: Flyway Migrations Based - Use the UNDO verb to rollback last deployed script against SHADOW environment
REM ===========================

REM Variables - Customize these for your environment
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\Chinook\SqlServer"
set "TARGET_ENVIRONMENT=shadow"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM Calculate the differences between two entities (Databases/Folders & More)
flyway undo info ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause