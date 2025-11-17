# Variables #
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila" 
$TARGET_ENVIRONMENT = "prod"
$TARGET_ENVIRONMENT_USERNAME = "postgres"
$TARGET_ENVIRONMENT_PASSWORD = "Redg@te1"

# Calculate the differences between two entities (Databases/Folders & More) #
flyway migrate info `
-environment="$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
-workingDirectory="$WORKING_DIRECTORY"