#!/bin/bash

# ===========================
# Script Name: 01_Flyway_State_Model.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Model verb to capture artifact differences to project Schema Model
# ===========================

# Variables #
ARTIFACT_FILENAME="Flyway.State.Development.differences-$(date +"%d-%m-%Y").zip"
WORKING_DIRECTORY="/mnt/c//GIT/Repos/MyProjectName" # Path to working directory

flyway model \
"-model.artifactFilename=$ARTIFACT_FILENAME" \
-workingDirectory="$WORKING_DIRECTORY"