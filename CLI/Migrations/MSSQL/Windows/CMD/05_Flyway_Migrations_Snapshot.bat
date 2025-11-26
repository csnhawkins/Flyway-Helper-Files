@echo off
REM ===========================
REM Script Name: 05_Flyway_Migrations_Snapshot.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-26
REM Description: Use the Snapshot verb to create a schema snapshot of target database
REM ===========================

REM Variables - Customize these for your environment
set "WORKING_DIRECTORY=C:\FlywayProjects\Migrations\MSSQL\Chinook"
set "TARGET_ENVIRONMENT=Test"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM Create Snapshot and save into snapshotHistory table
flyway snapshot ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-snapshot.filename="snapshotHistory:Snapshot-Static" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause