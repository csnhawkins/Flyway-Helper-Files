# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila" 
$SOURCE_ENVIRONMENT = "development"
$SOURCE_ENVIRONMENT_USERNAME = ""
$SOURCE_ENVIRONMENT_PASSWORD = ""
$TARGET_ENVIRONMENT = "schemaModel"

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""