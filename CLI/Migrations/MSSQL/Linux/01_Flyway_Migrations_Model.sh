#!/bin/bash

# ===========================
# Script Name: 01_Flyway_Migrations_Model.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway Migrations Based - Use the Model verb to capture artifact differences to project Schema Model
# ===========================

# Variables - Customize these for your environment #
ARTIFACT_FILENAME="Flyway.Development.differences-$(date +"%d-%m-%Y").zip"  # Input artifact file from diff operation
WORKING_DIRECTORY="/mnt/c/GIT/Repos/Local/State_MSSQL"  # Path to Flyway project root 

flyway model \
-model.artifactFilename="$ARTIFACT_FILENAME" \
-workingDirectory="$WORKING_DIRECTORY"