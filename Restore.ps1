$ErrorActionPreference = "Stop"

function exitOnError {
    param (
        [string[]] $Params
    )
    
    if ($LastExitCode -ne 0){
        foreach ($Param in $Params){
            Write-Host $Param -ForegroundColor red
        }
        exit 1
    }
}

if (!$args[0]) {
    Write-Host "Please S3 Object Name" -ForegroundColor red
    exit 1
}

if (!$args[1]) {
    Write-Host "Please specify Bucket Name" -ForegroundColor red
    exit 1
}

$name = [string] $args[0]

# Download 
$key = "s3://$($args[1])/$name";
Write-Host "Getting $key" -ForegroundColor green

aws s3 cp $key $name
exitOnError -Params "Error Getting $key", "Check bucket and object name"

# decompress
Write-Host "Decompressing $name" -ForegroundColor green
7z x $name -o*
exitOnError -Params "Error Decompressing $name"

# Remove
Write-Host "Deleting $name" -ForegroundColor green
Remove-Item $name

# for each file
Write-Host "Restoring" -ForegroundColor green
$folderPath = [string] $name.Substring(0,$name.Length-3)

Get-ChildItem $folderPath -Filter *.BAK | 
Foreach-Object {
    Write-Host "Restoring $($_.BaseName) from $($_.FullName)" -ForegroundColor green
    sqlcmd -Q "RESTORE DATABASE $($_.BaseName) FROM DISK = '$($_.FullName)'"
    exitOnError -Params "Error Restoring $($_.BaseName) from $($_.FullName)"
}

# Delete Folder
Write-Host "Removing $folderPath" -ForegroundColor green
Remove-Item $folderPath -Recurse

#Done
Write-Host "Done :)" -ForegroundColor green