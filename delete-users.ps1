# CAUTION MESSAGE
Write-Host "⚠️  WARNING: This script will permanently delete user folders in C:\Users" -ForegroundColor Red
Write-Host "Excluding: Administrator, user-PC, and itadmin" -ForegroundColor Yellow
Write-Host "User accounts will NOT be removed." -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "Type YES to proceed"

if ($confirm -ne "YES") {
    Write-Host "Operation cancelled." -ForegroundColor Cyan
    exit
}

# Excluded usernames
$excludedUsers = @("Administrator", "user-PC", "itadmin")

# Prepare log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path -Path $PSScriptRoot -ChildPath "DeletedUserFolders-$timestamp.log"
Add-Content -Path $logPath -Value "=== Folder Deletion Log ($timestamp) ===`r`n"

# Get user folders in C:\Users (excluding listed)
$userFolders = Get-ChildItem "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }

foreach ($folder in $userFolders) {
    $userFolder = $folder.FullName
    $folderSize = 0

    # Calculate folder size (in MB)
    try {
        $folderSize = (Get-ChildItem -Path $userFolder -Recurse -Force -ErrorAction SilentlyContinue |
                       Measure-Object -Property Length -Sum).Sum / 1MB
        $folderSize = [math]::Round($folderSize, 2)
    } catch {
        $folderSize = "Unknown"
    }

    # Try deleting
    try {
        Remove-Item -Path $userFolder -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Deleted folder: $($userFolder) ($folderSize MB)" -ForegroundColor Green
        Add-Content -Path $logPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - Deleted: $userFolder ($folderSize MB)"
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Error deleting folder $($userFolder): $($errorMessage)" -ForegroundColor Red
        Add-Content -Path $logPath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - FAILED: $userFolder - $errorMessage"
    }

    Write-Host ""
}

Write-Host "✅ Folder deletion complete. Log saved to:`n$logPath" -ForegroundColor Cyan
Read-Host "Press ENTER to exit"
