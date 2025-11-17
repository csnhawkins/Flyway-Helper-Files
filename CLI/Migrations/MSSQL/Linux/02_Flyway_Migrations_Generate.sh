#!/bin/bash

# ===========================
# Script Name: 00_Flyway_Migrations_Generate.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the DIFF & GENERATE verbs to create a Migration and Undo script for the changes found in the Schema Model
# ===========================

# Variables #
ARTIFACT_FILENAME="Flyway.Migrations.differences-$(date +"%d-%m-%Y").zip"
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL" 
SOURCE_ENVIRONMENT="schemaModel"
TARGET_ENVIRONMENT="migrations"
BUILD_ENVIRONMENT="shadow"
BUILD_ENVIRONMENT_USERNAME=""
BUILD_ENVIRONMENT_PASSWORD=""
FLYWAY_VERSION_DESCRIPTION="FlywayCLI_AutomatedMigrationScript"

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff generate \
"-diff.source=$SOURCE_ENVIRONMENT" \
"-diff.target=$TARGET_ENVIRONMENT" \
"-diff.buildEnvironment=$BUILD_ENVIRONMENT" \
"-environments.$BUILD_ENVIRONMENT.user=$BUILD_ENVIRONMENT_USERNAME" \
"-environments.$BUILD_ENVIRONMENT.password=$BUILD_ENVIRONMENT_PASSWORD" \
"-diff.artifactFilename=$ARTIFACT_FILENAME" \
"-generate.artifactFilename=$ARTIFACT_FILENAME" \
"-generate.description=$FLYWAY_VERSION_DESCRIPTION" \
"-generate.location=$WORKING_DIRECTORY/migrations" \
"-generate.types=versioned,undo" \
"-generate.addTimestamp=true" \
-workingDirectory="$WORKING_DIRECTORY" \
-schemaModelSchemas=""