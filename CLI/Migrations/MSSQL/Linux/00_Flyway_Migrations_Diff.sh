#!/bin/bash

# ===========================
# Script Name: 00_Flyway_Migrations_Diff.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the DIFF verb to create an artifact between two environments
# ===========================

# Variables #
ARTIFACT_FILENAME="Flyway.Development.differences-$(date +"%d-%m-%Y").zip"
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL" 
SOURCE_ENVIRONMENT="development"
SOURCE_ENVIRONMENT_USERNAME=""
SOURCE_ENVIRONMENT_PASSWORD=""
TARGET_ENVIRONMENT="schemaModel"

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff \
"-diff.source=$SOURCE_ENVIRONMENT" \
"-diff.target=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" \
"-diff.artifactFilename=$ARTIFACT_FILENAME" \
-schemaModelLocation="$WORKING_DIRECTORY/schema-model" \
-workingDirectory="$WORKING_DIRECTORY" \
-schemaModelSchemas=""