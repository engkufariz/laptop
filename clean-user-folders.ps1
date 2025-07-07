# === Initialization ===
$logPath = "$env:USERPROFILE\cleanup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
"Cleanup started on $(Get-Date)" | Out-File -FilePath $logPath

Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
Write-Host ""
Read-Host "Press Enter to continue"

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
    Add-Content -Path $logPath -Value "`n===== Folder: $folder ====="

    if (Test-Path $folder) {
        $confirmation = Read-Host "Do you want to delete all contents in this folder? (Y/N)"
        if ($confirmation -match '^[Yy]$') {
            try {
                $items = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction Stop
                $totalSize = 0

                foreach ($item in $items) {
                    if ($item.PSIsContainer -eq $false) {
                        $sizeMB = [math]::Round($item.Length / 1MB, 2)
                        $totalSize += $item.Length
                        Add-Content -Path $logPath -Value "$($item.FullName) - ${sizeMB}MB"
                    } else {
                        Add-Content -Path $logPath -Value "$($item.FullName)\ (folder)"
                    }
                }

                # Delete the items
                $items | Remove-Item -Recurse -Force -ErrorAction Stop
                $freedMB = [math]::Round($totalSize / 1MB, 2)
                Write-Host "Deleted all contents in $folder (Freed: $freedMB MB)" -ForegroundColor Green
                Add-Content -Path $logPath -Value "Total Freed Space: $freedMB MB"

            } catch {
                W
