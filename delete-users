# ⚠️ DANGER ZONE: Deletes local accounts and user folders
# Run this script as Administrator

Write-Host "⚠️ This script will permanently DELETE local user accounts and their profile folders in C:\Users EXCEPT for:" -ForegroundColor Red
Write-Host "   - Administrator" -ForegroundColor Yellow
Write-Host "   - user-PC" -ForegroundColor Yellow
Write-Host "   - itadmin" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type YES to confirm and proceed"
if ($confirm -ne "YES") {
    Write-Host "Cancelled by user. Exiting..." -ForegroundColor Gray
    exit
}

# Define exclusions
$excluded = @("Administrator", "user-PC", "itadmin")
$basePath = "C:\Users"
$logFile = "$env:USERPROFILE\remove-users-and-folders.log"

"--- Deletion started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ---`r`n" | Out-File $logFile -Encoding UTF8 -Append

# Get all local users
$localUsers = Get-LocalUser

foreach ($user in $localUsers) {
    $username = $user.Name

    if ($excluded -contains $username) {
        Write-Host "⏭️ Skipping account: $username" -ForegroundColor DarkGray
        continue
    }

    try {
        # Remove local user account
        Remove-LocalUser -Name $username -ErrorAction Stop
        Write-Host "🧹 Removed account: $username" -ForegroundColor Green
        "[ACCOUNT DELETED] $username" | Out-File $logFile -Append
    } catch {
        Write-Host "❌ Failed to remove account $username: $_" -ForegroundColor Red
        "[ERROR] Failed to delete account $username - $_" | Out-File $logFile -Append
        continue
    }

    # Attempt to delete user folder
    $userFolder = Join-Path $basePath $username
    if (Test-Path $userFolder) {
        try {
            $folderSize = (Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue -Path $userFolder | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($folderSize / 1MB, 2)

            Remove-Item -Path $userFolder -Recurse -Force -ErrorAction Stop
            Write-Host "🗑️ Deleted folder: $userFolder ($sizeMB MB)" -ForegroundColor Cyan
            "[FOLDER DELETED] $userFolder - $sizeMB MB" | Out-File $logFile -Append
        } catch {
            Write-Host "❌ Error deleting folder $userFolder: $_" -ForegroundColor Red
            "[ERROR] Failed to delete folder $userFolder - $_" | Out-File $logFile -Append
        }
    } else {
        Write-Host "⚠️ Folder not found: $userFolder" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "✅ DONE! Log saved to $logFile" -ForegroundColor Green
