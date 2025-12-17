@echo off
REM ===========================
REM Script Name: 03b_Flyway_Migrations_Check.bat
REM Version: 1.0.1
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-12-17
REM Description: Flyway Migrations Based - Use the CHECK verb to create a report detailing all pending changes/detected drift and code analysis
REM ===========================


REM Variables - Customize these for your environment
set "REPORT_FILENAME=Flyway-Check-All_Report.html"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\NewWorldDB"
set "REPORT_ENVIRONMENT=shadow"
set "REPORT_ENVIRONMENT_USERNAME="
set "REPORT_ENVIRONMENT_PASSWORD="
set "TARGET_ENVIRONMENT=test"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM NOTE: First-time execution warning
REM If this is the first time running check against the target environment, you may receive warnings about missing snapshots in the snapshotHistory table. Either Run:
REM - 03a_Flyway_Migrations_Snapshot.bat to create an initial snapshot, OR
REM - 04_Flyway_Migrations_Migrate.bat script (which can save snapshots automatically after deployment)

REM Create Check Report
flyway check -dryrun -changes -code -drift ^
-check.buildEnvironment="%REPORT_ENVIRONMENT%" ^
-environments.%REPORT_ENVIRONMENT%.user="%REPORT_ENVIRONMENT_USERNAME%" ^
-environments.%REPORT_ENVIRONMENT%.password="%REPORT_ENVIRONMENT_PASSWORD%" ^
-check.deployedSnapshot="snapshotHistory:current" ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-configFiles="%WORKING_DIRECTORY%\flyway.toml" ^
-workingDirectory="%WORKING_DIRECTORY%" ^
-reportFilename="%WORKING_DIRECTORY%\Artifact\%REPORT_FILENAME%"

pause
