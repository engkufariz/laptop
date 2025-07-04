# Display warning
Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
Write-Host ""
Pause

# Define log file location (e.g., Desktop)
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath = "$env:USERPROFILE\Desktop\clean-log_$timestamp.txt"
$totalBytesFreed = 0

# Write log header
Add-Content -Path $logPath -Value "=== Clean Folder Script Log ==="
Add-Content -Path $logPath -Value "Started: $(Get-Date)"
Add-Content -Path $logPath -Value ""

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
    Add-Content -Path $logPath -Value "`n--- Processing folder: $folder ---"

    if (Test-Path $folder) {
        $confirmation = Read-Host "Do you want to delete all contents in this folder? (Y/N)"
        if ($confirmation -match '^[Yy]$') {
            try {
                $items = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction Stop
                if ($items.Count -eq 0) {
                    Write-Host "No items found in $folder" -ForegroundColor DarkGray
                    Add-Content -Path $logPath -Value "No items found."
                } else {
                    foreach ($item in $items) {
                        try {
                            $size = if ($item.PSIsContainer) {
                                # Calculate folder size recursively
                                (Get-ChildItem -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                                 Measure-Object -Property Length -Sum).Sum
                            } else {
                                $item.Length
                            }

                            $size = $size ?? 0
                            $totalBytesFreed += $size
                            $sizeMB = "{0:N2}" -f ($size / 1MB)

                            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                            Add-Content -Path $logPath -Value "Deleted: $($item.FullName) - ${sizeMB} MB"
                        } catch {
                            Write-Host "Error deleting $($item.FullName): $_" -ForegroundColor Red
                            Add-Content -Path $logPath -Value "ERROR deleting $($item.FullName): $_"
                        }
                    }
                    Write-Host "Deleted all contents in $folder" -ForegroundColor Green
                }
            } catch {
                Write-Host "Error accessing $folder: $_" -ForegroundColor Red
                Add-Content -Path $logPath -Value "ERROR accessing $folder: $_"
            }
        } else {
            Write-Host "Skipped $folder" -ForegroundColor DarkGray
            Add-Content -Path $logPath -Value "Skipped by user."
        }
    } else {
        Write-Host "Folder not found: $folder" -ForegroundColor DarkGray
        Add-Content -Path $logPath -Value "Folder not found."
    }
}

# Summary
$totalMB = "{0:N2}" -f ($totalBytesFreed / 1MB)
Add-Content -Path $logPath -Value "`nTotal space freed: ${totalMB} MB"
Add-Content -Path $logPath -Value "Completed: $(Get-Date)"
Write-Host ""
Write-Host "DONE! Total space freed: ${totalMB} MB" -ForegroundColor Green
Write-Host "Log file saved to:`n$logPath" -ForegroundColor Cyan
Read-Host "Press ENTER to exit"
