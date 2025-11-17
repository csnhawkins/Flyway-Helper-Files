#!/bin/bash

# ===========================
# Script Name: 03_Flyway_State_Deploy.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
# ===========================

# Variables - Customize these for your environment #
SCRIPT_FILENAME="D_Flyway-Dryrun_Deployment_Script-$(date +"%d-%m-%Y").sql"  # Path to deployment script to execute
WORKING_DIRECTORY="/mnt/c/GIT/Repos/MyProjectName"  # Path to Flyway project root
TARGET_ENVIRONMENT="Test"  # Target database environment name
TARGET_ENVIRONMENT_USERNAME=""  # Target database username (leave empty for flyway.toml)
TARGET_ENVIRONMENT_PASSWORD=""  # Target database password (use env variables in production)

# Deploy Script to target #
flyway deploy \
"-environment=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-deploy.scriptFilename=$SCRIPT_FILENAME" \
-workingDirectory="$WORKING_DIRECTORY"