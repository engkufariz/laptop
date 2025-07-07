# Display caution message
Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Type YES to confirm and proceed"
if ($confirm -ne "YES") {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    exit
}

# Define target folders
$folders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music"
)

# Prepare log file
$logFile = "$env:USERPROFILE\delete-log.txt"
"[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Deletion started`r`n" | Out-File -FilePath $logFile -Encoding UTF8 -Append

# Loop through each folder and delete its contents
foreach ($folder in $folders) {
    Write-Host ""
    Write-Host "Start deleting all files and folders in: $folder" -ForegroundColor Cyan

    if (Test-Path $folder) {
        try {
            $deletedFiles = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction Stop |
                            Where-Object { -not $_.Attributes.ToString().Contains("Hidden") -and -not $_.Attributes.ToString().Contains("System") }

            $totalSize = 0
            foreach ($item in $deletedFiles) {
                $size = if ($item.PSIsContainer) { 0 } else { $item.Length }
                $totalSize += $size
                "[DELETED] $($item.FullName) - $([math]::Round($size / 1MB, 2)) MB" | Out-File -FilePath $logFile -Append -Encoding UTF8
            }

            $deletedFiles | Remove-Item -Force -Recurse -ErrorAction Stop
            Write-Host "✅ Deleted contents of: $folder" -ForegroundColor Green
            "Total Freed from $folder: $([math]::Round($totalSize / 1MB, 2)) MB`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8

        } catch {
            $errorMsg = $_.Exception.Message
            Write-Host "❌ Error deleting contents in $folder: $errorMsg" -ForegroundColor Red
            "[ERROR] $folder - $errorMsg`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8
        }
    } else {
        Write-Host "⚠️ Folder not found: $folder" -ForegroundColor DarkGray
        "[NOT FOUND] $folder`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8
    }
}

# End message
Write-Host ""
Write-Host "DONE! Deletion process completed. Log saved to: $logFile" -ForegroundColor Cyan
Read-Host "Press ENTER to exit"
