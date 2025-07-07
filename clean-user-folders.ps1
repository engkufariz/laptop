# Display caution message
Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
Write-Host ""
Read-Host "Press ENTER to continue..."

# Define target folders
$folders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music"
)

# Loop through each folder and delete its contents
foreach ($folder in $folders) {
    Write-Host ""
    Write-Host "Start deleting all files and folders in: $folder" -ForegroundColor Cyan

    if (Test-Path $folder) {
        try {
            # Delete contents only, not the folder itself
            Get-ChildItem -Path $folder -Force -Recurse | Remove-Item -Force -Recurse -ErrorAction Stop
            Write-Host "Deleted contents of: $folder" -ForegroundColor Green
        } catch {
            Write-Host "Error deleting contents in ${folder}: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Folder not found: $folder" -ForegroundColor DarkGray
    }
}

# End message
Write-Host ""
Read-Host "DONE! Press ENTER to exit."
