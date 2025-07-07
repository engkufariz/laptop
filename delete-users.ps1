# CAUTION MESSAGE
Write-Host "⚠️  WARNING: This script will permanently delete user folders and local accounts in C:\Users except for Administrator, user-PC, and itadmin." -ForegroundColor Red
Write-Host "Use this script with caution!" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type YES to proceed"

if ($confirm -ne "YES") {
    Write-Host "Operation cancelled." -ForegroundColor Cyan
    exit
}

# Define excluded usernames
$excludedUsers = @("Administrator", "user-PC", "itadmin")

# Get all user folders in C:\Users
$userFolders = Get-ChildItem "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }

foreach ($folder in $userFolders) {
    $username = $folder.Name
    $userFolder = $folder.FullName

    # Attempt to remove local user account
    try {
        $localUser = Get-LocalUser -Name $username -ErrorAction Stop
        Remove-LocalUser -Name $username -ErrorAction Stop
        Write-Host "✅ Local account removed: $username" -ForegroundColor Green
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Failed to remove account $($username): $($errorMessage)" -ForegroundColor Red
    }

    # Attempt to delete the user folder
    try {
        Remove-Item -Path $userFolder -Recurse -Force -ErrorAction Stop
        Write-Host "✅ Deleted folder: $userFolder" -ForegroundColor Green
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "❌ Error deleting folder $($userFolder): $($errorMessage)" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "✅ Script completed." -ForegroundColor Cyan
Read-Host "Press ENTER to exit"
