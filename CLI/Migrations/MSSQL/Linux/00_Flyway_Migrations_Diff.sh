#!/bin/bash

# ===========================
# Script Name: 00_Flyway_Migrations_Diff.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the DIFF verb to create an artifact between two environments
# ===========================

# Variables - Customize these for your environment #
ARTIFACT_FILENAME="Flyway.Development.differences-$(date +"%d-%m-%Y").zip"  # Output file for comparison results
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL"  # Path to Flyway project root
SOURCE_ENVIRONMENT="development"  # Source database environment name
SOURCE_ENVIRONMENT_USERNAME=""  # Source database username (leave empty for flyway.toml)
SOURCE_ENVIRONMENT_PASSWORD=""  # Source database password (use env variables in production)
TARGET_ENVIRONMENT="schemaModel"  # Target environment name (schemaModel for migrations)

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff \
    "-diff.source=$SOURCE_ENVIRONMENT" \\							# Source database to compare from
    "-diff.target=$TARGET_ENVIRONMENT" \\							# Target (schema model) to compare to
    "-environments.$SOURCE_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" \\	# Database username for source environment
    "-environments.$SOURCE_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" \\	# Database password for source environment
    "-diff.artifactFilename=$ARTIFACT_FILENAME" \\					# Output file for differences
    "-schemaModelLocation=$WORKING_DIRECTORY/schema-model" \\			# Location of your schema model files
    "-workingDirectory=$WORKING_DIRECTORY" \\						# Flyway project root directory
    "-schemaModelSchemas=" 										# Schemas to include (empty = all schemas)

# =============================================================================
# NEXT STEPS:
# 1. Review the generated artifact file to understand what changes were detected
# 2. If changes look correct, proceed to: 01_Flyway_Migrations_Model.sh
# 3. Generate migration scripts with: 02_Flyway_Migrations_Generate.sh
# 4. Deploy migrations with: 03_Flyway_Migrations_Migrate.sh
# =============================================================================