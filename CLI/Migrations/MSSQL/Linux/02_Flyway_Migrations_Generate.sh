#!/bin/bash

# ===========================
# Script Name: 02_Flyway_Migrations_Generate.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the DIFF & GENERATE verbs to create a Migration and Undo script for the changes found in the Schema Model
# ===========================

# Variables - Customize these for your environment #
ARTIFACT_FILENAME="Flyway.Migrations.differences-$(date +"%d-%m-%Y").zip"  # Output file for generated migrations
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL"  # Path to Flyway project root
SOURCE_ENVIRONMENT="schemaModel"  # Source environment name (desired state)
TARGET_ENVIRONMENT="migrations"  # Target environment name (existing migrations)
BUILD_ENVIRONMENT="shadow"  # Build database environment name for validation
BUILD_ENVIRONMENT_USERNAME=""  # Build database username (leave empty for flyway.toml)
BUILD_ENVIRONMENT_PASSWORD=""  # Build database password (use env variables in production)
FLYWAY_VERSION_DESCRIPTION="FlywayCLI_AutomatedMigrationScript"  # Description for migration script filename

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