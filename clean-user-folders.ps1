Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
Write-Host ""
Pause

# List of user folders
$folders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music"
)

foreach ($folder in $folders) {
    Write-Host ""
    Write-Host "Target folder: $folder" -ForegroundColor Cyan

    if (Test-Path $folder) {
        $confirmation = Read-Host "Do you want to delete all contents in this folder? (Y/N)"
        if ($confirmation -match '^[Yy]$') {
            try {
                Get-ChildItem -Path $folder -Recurse -Force -ErrorAction Stop | Remove-Item -Recurse -Force -ErrorAction Stop
                Write-Host "Deleted all contents in $folder" -ForegroundColor Green
            } catch {
                Write-Host "Error deleting contents in $folder: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "Skipped $folder" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "Folder not found: $folder" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "DONE! Press ENTER to exit." -ForegroundColor Cyan
Read-Host
