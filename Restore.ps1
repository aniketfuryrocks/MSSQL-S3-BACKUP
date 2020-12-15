if (!$args[0]) {
    Write-Host "Please S3 Object Name" -ForegroundColor red
    exit 1
}

$name = [string] $args[0]

aws s3 cp s3://busy-backups/$name $name

7z x $name -o*

# Remove
Remove-Item $name

# for each file

$folderPath = [string] $name.Substring(0,$name.Length-3)

Get-ChildItem $folderPath -Filter *.BAK | 
Foreach-Object {
    sqlcmd -Q "RESTORE DATABASE $($_.BaseName) FROM DISK = '$($_.FullName)'"
}

# Delete Folder
Remove-Item $folderPath -Recurse
