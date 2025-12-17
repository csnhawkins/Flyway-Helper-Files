# ===========================
# Script Name: 03_Flyway_Migrations_Check.ps1
# Version: 1.0.1
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-12-16
# Description: Flyway Migrations Based - Use the CHECK verb to create a report detailing all pending changes/detected drift and code analysis
# ===========================


# Variables - Customize these for your environment #
$REPORT_FILENAME = "Flyway-Check-All_Report.html"  # Output deployment script name
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\NewWorldDB"  # Path to Flyway state-based project root
$REPORT_ENVIRONMENT = "shadow"  # Sandbox environment name
$REPORT_ENVIRONMENT_USERNAME = ""  # Sandbox database username (leave empty for flyway.toml)
$REPORT_ENVIRONMENT_PASSWORD = ""  # Sandbox database password (use env variables in 
$TARGET_ENVIRONMENT = "test"  # Target database environment name
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)

# NOTE: First-time execution warning #
# If this is the first time running check against the target environment, you may receive warnings about missing snapshots in the snapshotHistory table. Either Run:
# - 03a_Flyway_Migrations_Snapshot.ps1 to create an initial snapshot, OR
# - 04_Flyway_Migrations_Migrate.ps1 script (which can save snapshots automatically after deployment)

# Create Check Report #
flyway check -dryrun -changes -code -drift `
"-check.buildEnvironment=$REPORT_ENVIRONMENT" `
"-environments.$REPORT_ENVIRONMENT.user=$REPORT_ENVIRONMENT_USERNAME" `
"-environments.$REPORT_ENVIRONMENT.password=$REPORT_ENVIRONMENT_PASSWORD" `
"-check.deployedSnapshot=snapshotHistory:current" `
"-environment=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-configFiles="$WORKING_DIRECTORY\flyway.toml" `
-workingDirectory="$WORKING_DIRECTORY" `
"-reportFilename=$WORKING_DIRECTORY\Artifact\$REPORT_FILENAME"