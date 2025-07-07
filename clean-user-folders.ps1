# Requires PowerShell 5+ and Microsoft.VisualBasic for Recycle Bin support
Add-Type -AssemblyName Microsoft.VisualBasic

# Display warning
Write-Host "⚠️  SAFE DELETE MODE - Files will be moved to Recycle Bin instead of permanent deletion." -ForegroundColor Yellow
Write-Host "This includes folders: Downloads, Documents, Pictures, Videos, Music"
Write-Host ""
Read-Host "Press ENTER to continue..."

# Create log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = "$env:USERPROFILE\Desktop\recycle_log_$timestamp.txt"
New-Item -Path $logPath -ItemType File -Force | Out-Null

# Target folders
$folders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music"
)

# Function to send to Recycle Bin using .NET
function Send-ToRecycleBin {
    param ([string]$path)

    try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
            $path,
            'OnlyErrorDialogs',
            'SendToRecycleBin'
        )
        return $true
    } catch {
        return $false
    }
}

# Loop through folders
foreach ($folder in $folders) {
    Write-Host ""
    Write-Host "Target folder: $folder" -ForegroundColor Cyan

    if (Test-Path $folder) {
        $confirmation = Read-Host "Do you want to MOVE this folder to Recycle Bin? (Y/N)"
        if ($confirmation -match '^[Yy]$') {
            try {
                # Calculate folder size and count
                $items = Get-ChildItem -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
                $totalSize = ($items | Measure-Object -Property Length -Sum).Sum
                $fileCount = ($items | Where-Object { -not $_.PSIsContainer }).Count
                $folderCount = ($items | Where-Object { $_.PSIsContainer }).Count
                $sizeMB = [math]::Round($totalSize / 1MB, 2)

                # Send to Recycle Bin
                $result = Send-ToRecycleBin -path $folder

                if ($result) {
                    $logEntry = @"
[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]
Moved to Recycle Bin: $folder
Total size: ${sizeMB} MB
Files: $fileCount
Folders: $folderCount
--------------------------
"@
                    Add-Content -Path $logPath -Value $logEntry
                    Write-Host "Moved to Recycle Bin: $folder ($sizeMB MB, $fileCount files, $folderCount folders)" -ForegroundColor Green
                } else {
                    throw "Failed to move to Recycle Bin"
                }
            } catch {
                Write-Host "❌ Error processing $folder: $_" -ForegroundColor Red
                Add-Content -Path $logPath -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] ERROR processing $folder: $_`r`n"
            }
        } else {
            Write-Host "Skipped: $folder" -ForegroundColor DarkGray
            Add-Content -Path $logPath -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Skipped: $folder`r`n"
        }
    } else {
        Write-Host "Folder not found: $folder" -ForegroundColor DarkGray
        Add-Content -Path $logPath -Value "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Folder not found: $folder`r`n"
    }
}

Write-Host "`n✅ DONE! Folders sent to Recycle Bin. Log saved to: $logPath" -ForegroundColor Cyan
Read-Host "Press ENTER to exit."
