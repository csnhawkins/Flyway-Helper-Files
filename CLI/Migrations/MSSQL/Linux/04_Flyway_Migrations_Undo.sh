#!/bin/bash

# ===========================
# Script Name: 00_Flyway_Migrations_Undo.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the UNDO verb to rollback last deployed script against SHADOW environment
# ===========================

# Variables #
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL" 
$TARGET_ENVIRONMENT = "shadow"
$TARGET_ENVIRONMENT_USERNAME = ""
$TARGET_ENVIRONMENT_PASSWORD = ""

# Calculate the differences between two entities (Databases/Folders & More) #
flyway undo info \
-environment="$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
-workingDirectory="$WORKING_DIRECTORY"