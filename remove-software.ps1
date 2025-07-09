Clear-Host
Write-Host "==============================================="
Write-Host "   REMOVE INSTALLED SOFTWARE (v1.0)" -ForegroundColor Cyan
Write-Host "==============================================="
# Display script information
Write-Host "REMOVE INSTALLED SOFTWARE - This script will display all installed software and user need to choose which software to be uninstalled (batch)."
Write-Host ""
Read-Host "Press Enter to continue"
Write-Host "Start retrieving all details:"
Write-Host ""

# Run as Administrator

function Get-InstalledSoftware {
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $softwareList = foreach ($path in $regPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.UninstallString } |
        Select-Object DisplayName, UninstallString
    }
    return $softwareList | Sort-Object DisplayName -Unique
}

function Select-SoftwareToUninstall($softwareList) {
    $softwareList | ForEach-Object -Begin { $i = 1 } -Process {
        Write-Host "$i. $($_.DisplayName)"
        $_ | Add-Member -MemberType NoteProperty -Name Index -Value $i
        $i++
    }

    $selection = Read-Host "`nEnter the number(s) of software to uninstall (comma-separated)"
    $indexes = $selection -split "," | ForEach-Object { $_.Trim() -as [int] }
    return $softwareList | Where-Object { $indexes -contains $_.Index }
}

function Uninstall-Software($apps) {
    foreach ($app in $apps) {
        $displayName = $app.DisplayName
        $uninstallCmd = $app.UninstallString

        Write-Host "`n[+] Launching uninstaller for: $displayName"

        try {
            # Handle uninstall command (msiexec or EXE)
            if ($uninstallCmd -match '^".+"$') {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$uninstallCmd`"" -Wait -NoNewWindow
            }

            Write-Host "[✔] Uninstaller launched: $displayName"
        } catch {
            Write-Warning "[!] Failed to launch uninstaller for $displayName - $_"
        }
    }
}

# --- Main Execution ---

$softwareList = Get-InstalledSoftware

if ($softwareList.Count -eq 0) {
    Write-Host "No uninstallable software found." -ForegroundColor Yellow
    exit
}

$selectedApps = Select-SoftwareToUninstall $softwareList

if ($selectedApps.Count -eq 0) {
    Write-Host "No software selected. Exiting." -ForegroundColor Yellow
    exit
}

Uninstall-Software $selectedApps
