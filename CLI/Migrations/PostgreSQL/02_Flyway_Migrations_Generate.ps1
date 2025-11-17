# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Migrations.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila" 
$SOURCE_ENVIRONMENT = "schemaModel"
$TARGET_ENVIRONMENT = "migrations"
$BUILD_ENVIRONMENT = "shadow"
$BUILD_ENVIRONMENT_USERNAME = "postgres"
$BUILD_ENVIRONMENT_PASSWORD = "Redg@te1"
$FLYWAY_VERSION_DESCRIPTION = "FlywayCLI_AutomatedMigrationScript"

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff generate `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-diff.buildEnvironment=$BUILD_ENVIRONMENT" `
"-environments.$BUILD_ENVIRONMENT.user=$BUILD_ENVIRONMENT_USERNAME" `
"-environments.$BUILD_ENVIRONMENT.password=$BUILD_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
"-generate.artifactFilename=$ARTIFACT_FILENAME" `
"-generate.description=$FLYWAY_VERSION_DESCRIPTION" `
"-generate.location=$WORKING_DIRECTORY\migrations" `
"-generate.types=versioned,undo" `
"-generate.addTimestamp=true" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""