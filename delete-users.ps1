# Define users to exclude
$excludedUsers = @("Administrator", "user-PC", "itadmin")

# Get timestamp and prepare log path
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logPath = Join-Path -Path $logDirectory -ChildPath "DeletedUserFolders-$timestamp.log"
Add-Content -Path $logPath -Value "=== Folder Deletion Log ($timestamp) ===`r`n"

# Get all user folders in C:\Users
$userFolders = Get-ChildItem -Path "C:\Users" -Directory | Where-Object {
    $excludedUsers -notcontains $_.Name
}

# Display all folders and sizes before deletion
Write-Host "📋 The following folders will be scanned for deletion:" -ForegroundColor Yellow
foreach ($folder in $userFolders) {
    try {
        $size = (Get-ChildItem -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-Host "$($folder.Name) - $sizeMB MB" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠️  Error reading size of $($folder.FullName)" -ForegroundColor Red
    }
}

# Confirm deletion
$confirm = Read-Host "`nType YES to delete all the above folders"
if ($confirm -ne "YES") {
    Write-Host "❌ Operation cancelled." -ForegroundColor Red
    exit
}

# Delete each folder and log the action
foreach ($folder in $userFolders) {
    $folderPath = $folder.FullName
    try {
        $size = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)

        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Deleted: $folderPath ($sizeMB MB)" -ForegroundColor Green
        Add-Content -Path $logPath -Value "Deleted: $folderPath - $sizeMB MB"
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Error deleting $folderPath: $errorMessage" -ForegroundColor Red
        Add-Content -Path $logPath -Value "ERROR deleting $folderPath: $errorMessage"
    }
}

Write-Host "`n✔️  All done. Log saved to: $logPath" -ForegroundColor Cyan
