#!/bin/bash

# ===========================
# Script Name: 01_Flyway_State_Prepare.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the PREPARE verb to create deployment script between two environments (By default - Changes in the Schema Model not in the Test environment)
# ===========================

# Variables #
SCRIPT_FILENAME="Flyway-Dryrun_Deployment_Script-$(date +"%d-%m-%Y").sql"
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL" # Path to working directory
SOURCE_ENVIRONMENT="schemaModel" # Source Comparison Environment (By default this is the Schema Model)
TARGET_ENVIRONMENT="Test" # Target Comparison Environment (By defauly this is an environment with an id of 'Test')
TARGET_ENVIRONMENT_USERNAME=""
TARGET_ENVIRONMENT_PASSWORD=""

# Prepare Script for Deployment #
flyway prepare \
"-prepare.source=$SOURCE_ENVIRONMENT" \
"-prepare.target=$TARGET_ENVIRONMENT" \
"-prepare.types=deploy,undo" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-prepare.scriptFilename=D_$SCRIPT_FILENAME" \
"-prepare.undoFilename=U_$SCRIPT_FILENAME" \
"-prepare.force=true" \
-configFiles="$WORKING_DIRECTORY/flyway.toml" \
-schemaModelLocation="$WORKING_DIRECTORY/schema-model"