@echo off
REM ===========================
REM Script Name: 01_Flyway_Migrations_Model.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway Migrations Based - Use the Model verb to capture artifact differences to project Schema Model
REM ===========================

REM Variables - Customize these for your environment
set "ARTIFACT_FILENAME=%temp%\Artifacts\Flyway.Development.differences.zip"
set "WORKING_DIRECTORY=C:\FlywayProjects\Migrations\MSSQL\Chinook"

flyway model ^
"-model.artifactFilename=%ARTIFACT_FILENAME%" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause