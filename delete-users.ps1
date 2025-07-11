Clear-Host
Write-Host "==============================================="
Write-Host "   DELETE USERS FOLDERS (v1.0)" -ForegroundColor Cyan
Write-Host "==============================================="
# Display caution
Write-Host "⚠️  This script will DELETE user folders in C:\Users EXCEPT the following:" -ForegroundColor Red
Write-Host "    - Administrator" -ForegroundColor Yellow
Write-Host "    - user-PC" -ForegroundColor Yellow
Write-Host "    - itadmin" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type YES to confirm and proceed..."
if ($confirm -ne "YES") {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    exit
}
Write-Host "📁 Folders marked for deletion:" -ForegroundColor Cyan

# Define excluded usernames
$excludedUsers = @('Administrator', 'user-PC', 'itadmin')

# Get user profile folders
$userFolders = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }

# Exit if no folders found
if ($userFolders.Count -eq 0) {
    Write-Host "No folders found for deletion." -ForegroundColor Yellow
    exit
}

# Display folders to be deleted
foreach ($folder in $userFolders) {
    Write-Host " - $($folder.FullName)"
}

# Confirm deletion
$confirm = Read-Host "`nType YES to confirm deletion"
if ($confirm -ne "YES") {
    Write-Host "Aborted by user." -ForegroundColor Yellow
    exit
}

# Set log file path
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = "C:\Users\Public\delete_folders_log_$timestamp.txt"

# Delete folders and log
foreach ($folder in $userFolders) {
    $folderPath = $folder.FullName
    try {
        # Calculate folder size
        $size = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = "{0:N2}" -f ($size / 1MB)

        # Delete folder
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Deleted: $folderPath ($sizeMB MB)" -ForegroundColor Green
        Add-Content -Path $logPath -Value "DELETED: ${folderPath} - ${sizeMB} MB"
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Error deleting ${folderPath}: ${errorMessage}" -ForegroundColor Red
        Add-Content -Path $logPath -Value "ERROR deleting ${folderPath}: ${errorMessage}"
    }
}

Write-Host "`n📝 Log saved to: $logPath" -ForegroundColor Cyan
Read-Host "`nDONE! Press ENTER to exit"
