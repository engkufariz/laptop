Clear-Host
Write-Host "============================================="
Write-Host "          POWERFUL CLEAN-UP TOOLKIT          " -ForegroundColor Cyan
Write-Host "============================================="

function Show-Menu {
    Write-Host "`n1. Show User + Laptop Info"
    Write-Host "2. Delete ALL User Profiles (excluding safe list)"
    Write-Host "3. Delete Personal Folders (Downloads, Documents, etc.)"
    Write-Host "4. Uninstall Installed Software (select manually)"
    Write-Host "5. Exit`n"
}

function Run-UserLaptopInfo {
    Write-Host "`n=== USER + LAPTOP INFO ===" -ForegroundColor Cyan
    try {
        $UserID = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $User = ([ADSI]"WinNT://$env:COMPUTERNAME/$env:USERNAME,user")
        $FullName = $User.FullName
        $HostName = $env:COMPUTERNAME
        $Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
        $Serial = (Get-WmiObject Win32_BIOS).SerialNumber
        $IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
            $_.InterfaceAlias -match "Ethernet" -and $_.IPAddress -notmatch "^169\.254\."
        } | Select-Object -First 1 -ExpandProperty IPAddress)

        Write-Host "Login ID     : $UserID"
        Write-Host "Full Name    : $FullName"
        Write-Host "Hostname     : $HostName"
        Write-Host "Model        : $Model"
        Write-Host "Serial       : $Serial"
        Write-Host "IP Address   : $IP"
        Write-Host "`nPing 10.32.240.20:"
        Test-Connection 10.32.240.20 -Count 4
    } catch {
        Write-Host "ERROR: $_" -ForegroundColor Red
    }
}

function Run-DeleteUserProfiles {
    Write-Host "`n⚠️  WARNING: This will DELETE all user folders in C:\Users except 'Administrator', 'user-PC', 'itadmin'"
    $confirm = Read-Host "Type YES to confirm and proceed"
    if ($confirm -ne "YES") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }

    $excludedUsers = @('Administrator', 'user-PC', 'itadmin')
    $userFolders = Get-ChildItem "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }

    $logPath = "C:\Users\Public\delete_user_profiles_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    foreach ($folder in $userFolders) {
        try {
            $size = (Get-ChildItem $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $sizeMB = "{0:N2}" -f ($size / 1MB)
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Deleted: $($folder.FullName) ($sizeMB MB)"
            Add-Content -Path $logPath -Value "DELETED: $($folder.FullName) - $sizeMB MB"
        } catch {
            Write-Host "❌ Error: $($folder.FullName) - $_" -ForegroundColor Red
            Add-Content -Path $logPath -Value "ERROR: $($folder.FullName) - $_"
        }
    }

    Write-Host "`n📝 Log saved to: $logPath"
}

function Run-DeletePersonalFolders {
    Write-Host "`n⚠️  WARNING: This will DELETE contents of Downloads, Documents, Pictures, Videos, Music."
    $confirm = Read-Host "Type YES to confirm and proceed"
    if ($confirm -ne "YES") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }

    $folders = @("Downloads", "Documents", "Pictures", "Videos", "Music") | ForEach-Object { "$env:USERPROFILE\$_" }
    $logFile = "$env:USERPROFILE\delete-log.txt"

    foreach ($folder in $folders) {
        Write-Host "`nProcessing: $folder"
        if (Test-Path $folder) {
            try {
                $items = Get-ChildItem $folder -Recurse -Force | Where-Object {
                    -not $_.Attributes.ToString().Contains("Hidden") -and -not $_.Attributes.ToString().Contains("System")
                }

                $totalSize = 0
                foreach ($item in $items) {
                    $size = if ($item.PSIsContainer) { 0 } else { $item.Length }
                    $totalSize += $size
                    Add-Content -Path $logFile -Value "[DELETED] $($item.FullName) - $([math]::Round($size / 1MB, 2)) MB"
                }
                $items | Remove-Item -Recurse -Force
                Write-Host "✅ Deleted contents of: $folder ($([math]::Round($totalSize / 1MB, 2)) MB)"
            } catch {
                Write-Host "❌ Error deleting $folder - $_" -ForegroundColor Red
                Add-Content -Path $logFile -Value "[ERROR] $folder - $_"
            }
        } else {
            Write-Host "⚠️ Folder not found: $folder"
        }
    }

    Write-Host "`n📝 Log saved to: $logFile"
}

function Run-UninstallSoftware {
    Write-Host "`n⚠️  This will show installed software and allow manual uninstallation."
    $confirm = Read-Host "Type YES to confirm and proceed"
    if ($confirm -ne "YES") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        return
    }

    function Get-InstalledSoftware {
        $paths = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        $softwareList = foreach ($path in $paths) {
            Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
                $_.DisplayName -and $_.UninstallString
            } | Select-Object DisplayName, UninstallString
        }
        return $softwareList | Sort-Object DisplayName -Unique
    }

    $softwareList = Get-InstalledSoftware
    if (-not $softwareList) {
        Write-Host "No uninstallable software found." -ForegroundColor Yellow
        return
    }

    $softwareList | ForEach-Object -Begin { $i = 1 } -Process {
        $_ | Add-Member -MemberType NoteProperty -Name Index -Value $i -Force
        Write-Host "$i. $($_.DisplayName)"
        $i++
    }

    $choice = Read-Host "`nEnter number(s) to uninstall (comma-separated)"
    $indexes = $choice -split "," | ForEach-Object { $_.Trim() -as [int] }
    $selected = $softwareList | Where-Object { $indexes -contains $_.Index }

    if (-not $selected) {
        Write-Host "No software selected."
        return
    }

    foreach ($app in $selected) {
        $name = $app.DisplayName
        $cmd = $app.UninstallString
        Write-Host "`nUninstalling: $name"
        try {
            if ($cmd -match '^".+"$') {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $cmd" -Wait -NoNewWindow
            } else {
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cmd`"" -Wait -NoNewWindow
            }
            Write-Host "[✔] Uninstaller launched: $name"
        } catch {
            Write-Host "[!] Failed to uninstall $name - $_" -ForegroundColor Red
        }
    }
}

do {
    Show-Menu
    $choice = Read-Host "`nEnter your choice (1-5)"
    switch ($choice) {
        "1" { Run-UserLaptopInfo }
        "2" { Run-DeleteUserProfiles }
        "3" { Run-DeletePersonalFolders }
        "4" { Run-UninstallSoftware }
        "5" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid selection. Try again." -ForegroundColor Yellow }
    }
} while ($true)
