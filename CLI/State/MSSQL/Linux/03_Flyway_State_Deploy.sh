#!/bin/bash

# ===========================
# Script Name: 01_Flyway_State_Deploy.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
# ===========================

# Variables #
SCRIPT_FILENAME="Flyway-Dryrun_Deployment_Script-$(date +"%d-%m-%Y").sql"
WORKING_DIRECTORY="/mnt/c//GIT/Repos/MyProjectName" # Path to working directory
TARGET_ENVIRONMENT="Test"
TARGET_ENVIRONMENT_USERNAME=""
TARGET_ENVIRONMENT_PASSWORD=""

# Deploy Script to target #
flyway deploy \
"-environment=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-deploy.scriptFilename=$SCRIPT_FILENAME" \
-workingDirectory="$WORKING_DIRECTORY"