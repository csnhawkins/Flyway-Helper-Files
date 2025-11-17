# Variables #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\Pagila" 

flyway model `
"-model.artifactFilename=$ARTIFACT_FILENAME" `
-workingDirectory="$WORKING_DIRECTORY"