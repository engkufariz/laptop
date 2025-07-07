# PowerShell Script: delete-user-folders.ps1

# Display warning
Write-Host "⚠️  This script will DELETE user folders under C:\Users (excluding Administrator, itadmin, and user-PC)" -ForegroundColor Red
Write-Host ""
Read-Host "Type YES to continue"

# Exclusions
$excludedUsers = @("Administrator", "itadmin", "user-PC")

# Set log path
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = "C:\Logs\DeletedUserFolders-$timestamp.log"
New-Item -ItemType File -Path $logPath -Force | Out-Null

# Get user folders
$userFolders = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }

# Display folders
Write-Host "`n📂 The following folders will be deleted:" -ForegroundColor Yellow
$userFolders | ForEach-Object { Write-Host $_.FullName -ForegroundColor Cyan }

# Confirm
$confirm = Read-Host "`nType YES to confirm deletion"
if ($confirm -ne "YES") {
    Write-Host "❌ Operation cancelled." -ForegroundColor Red
    exit
}

# Loop through and delete
foreach ($folder in $userFolders) {
    $folderPath = $folder.FullName
    Write-Host "`nProcessing: $folderPath" -ForegroundColor White

    # Take ownership and grant permissions
    try {
        Start-Process -FilePath "takeown.exe" -ArgumentList "/F `"$folderPath`" /R /D Y" -NoNewWindow -Wait
        Start-Process -FilePath "icacls.exe" -ArgumentList "`"$folderPath`" /grant administrators:F /T /C" -NoNewWindow -Wait
    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "❌ Failed to set permissions on $folderPath: $errorMsg" -ForegroundColor Red
        Add-Content -Path $logPath -Value "[ERROR] Failed to set permissions on $folderPath: $errorMsg"
        continue
    }

    # Get folder size
    try {
        $sizeBytes = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = "{0:N2}" -f ($sizeBytes / 1MB)
    } catch {
        $sizeMB = "Unknown"
    }

    # Delete folder
    try {
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Deleted: $folderPath ($sizeMB MB)" -ForegroundColor Green
        Add-Content -Path $logPath -Value "[DELETED] $folderPath - $sizeMB MB"
    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "❌ Error deleting $folderPath: $errorMsg" -ForegroundColor Red
        Add-Content -Path $logPath -Value "[ERROR] Failed to delete $folderPath: $errorMsg"
    }
}

Write-Host "`n✔️  All done. Log saved to: $logPath" -ForegroundColor Green
Pause
