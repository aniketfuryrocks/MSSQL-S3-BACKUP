if (!$args[0]) {
    Write-Host "Please specify Backup Path" -ForegroundColor red
    exit 1
}

if (!$args[0]) {
    Write-Host "Please specify Bucket Name" -ForegroundColor red
    exit 1
}

if (!($args[0] | Test-Path)) {
    Write-Host "Specified Backup Path Does Not exist" -ForegroundColor red
    exit 1;
}

$folderName = (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss");
$folderPath = -join($args[0],$folderName)

if ($folderPath | Test-Path) {
    Write-Host "Backup folder already exists" $folderPath -ForegroundColor red
    exit 1;
}

# Create Folder
New-Item -ItemType directory -Path $folderPath

# Make Path Absolute
$folderPath = $folderPath | Resolve-Path

# Backup
Write-Host "Backing up to Dir :" $folderPath -ForegroundColor green
sqlcmd -Q "DECLARE @name VARCHAR(50) DECLARE @path VARCHAR(256) DECLARE @fileName VARCHAR(256) SET @path = '$($folderPath)\' DECLARE db_cursor CURSOR READ_ONLY FOR SELECT name FROM master.sys.databases WHERE name NOT IN ('master','model','msdb','tempdb') AND state = 0 AND is_in_standby = 0 OPEN db_cursor FETCH NEXT FROM db_cursor INTO @name WHILE @@FETCH_STATUS = 0 BEGIN SET @fileName = @path + @name + '.BAK' BACKUP DATABASE @name TO DISK = @fileName; FETCH NEXT FROM db_cursor INTO @name END CLOSE db_cursor DEALLOCATE db_cursor"

# Compress
$zipPath = -join($folderPath,".7z")
Write-Host "Compressing Backup to file" $zipPath -ForegroundColor green
7z a $($zipPath) "$folderPath\*"

# Copy To AWS
Write-Host "Pushing zip to s3" -ForegroundColor green
aws s3 cp $zipPath s3://$args[1]

# Removing Folder
Write-Host "Removing folder" -ForegroundColor green
Remove-Item $folderPath -Recurse