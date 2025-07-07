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

        Write-Host "`n[+] Uninstalling: $displayName"

        try {
            # Adjust uninstall string for silent mode
            if ($uninstallCmd -match "msiexec\.exe") {
                if ($uninstallCmd -notmatch "/quiet") {
                    $uninstallCmd += " /quiet /norestart"
                }
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait -NoNewWindow
            } else {
                # Some EXE uninstallers may support /S or /silent
                if ($uninstallCmd -notmatch "/S") {
                    $uninstallCmd += " /S"
                }

                # Handle quoted paths
                if ($uninstallCmd -notmatch '^".+"$') {
                    $uninstallCmd = "`"$uninstallCmd`""
                }

                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait -NoNewWindow
            }

            Write-Host "[✔] Uninstalled: $displayName"
        } catch {
            Write-Warning "[!] Failed to uninstall $displayName - $_"
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
