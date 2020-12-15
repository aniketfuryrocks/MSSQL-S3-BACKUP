# MSSQL-S3-BACKUP
MsSQL backup and restore utility with s3 for windows

## Requirements :

+ Correctly Configured Aws Cli
+ 7zip

## Backup

> Backup.ps1 *backup-dir* *bucket-name*

The Backup script backs up all databases to the specified directory,
compressed it to `.7z` using `7zip`, pushes the .7z file to s3 bucket and then deletes the directory. Leaving behind the compressed .7z file.
 
## Restore

> Restore.ps1 *object-name* *bucket-name*

The restore script downloads the specified `.7z` file from s3, decompresses it to the base name of the file, deletes the file and then for every backup in the directory, it restores it to the basename of `.BKP` files.
