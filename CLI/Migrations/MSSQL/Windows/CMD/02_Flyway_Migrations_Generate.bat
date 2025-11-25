@echo off
REM ===========================
REM Script Name: 02_Flyway_Migrations_Generate.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway Migrations Based - Use the DIFF & GENERATE verbs to create a Migration and Undo script for the changes found in the Schema Model
REM ===========================

REM Variables - Customize these for your environment
set "ARTIFACT_FILENAME=%temp%\Artifacts\Flyway.Migrations.differences.zip"
set "WORKING_DIRECTORY=C:\FlywayProjects\Migrations\MSSQL\Chinook"
set "SOURCE_ENVIRONMENT=schemaModel"
set "TARGET_ENVIRONMENT=migrations"
set "BUILD_ENVIRONMENT=shadow"
set "BUILD_ENVIRONMENT_USERNAME="
set "BUILD_ENVIRONMENT_PASSWORD="
set "FLYWAY_VERSION_DESCRIPTION=FlywayCLI_AutomatedMigrationScript"

REM Calculate the differences between two entities (Databases/Folders & More)
flyway diff generate ^
"-diff.source=%SOURCE_ENVIRONMENT%" ^
"-diff.target=%TARGET_ENVIRONMENT%" ^
"-diff.buildEnvironment=%BUILD_ENVIRONMENT%" ^
"-environments.%BUILD_ENVIRONMENT%.user=%BUILD_ENVIRONMENT_USERNAME%" ^
"-environments.%BUILD_ENVIRONMENT%.password=%BUILD_ENVIRONMENT_PASSWORD%" ^
"-diff.artifactFilename=%ARTIFACT_FILENAME%" ^
"-generate.artifactFilename=%ARTIFACT_FILENAME%" ^
"-generate.description=%FLYWAY_VERSION_DESCRIPTION%" ^
"-generate.location=%WORKING_DIRECTORY%\migrations" ^
"-generate.types=versioned,undo" ^
-schemaModelLocation="%WORKING_DIRECTORY%\schema-model" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause