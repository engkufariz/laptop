function Show-Menu {
    Clear-Host
	Write-Host "============================================"
	Write-Host "		TCMY TOOLKIT 2025		"-ForegroundColor Cyan
	Write-Host "============================================"
	Write-Host ""
	Write-Host "`n1. Show User + Laptop Info"
	Write-Host "2. Network Troubleshooting Tools"
	Write-Host "3. System Troubleshooting Tools"
	Write-Host "4. Domain Troubleshooting Tools"
    Write-Host "5. Caution! - Delete All Users Folders in C:\Users"
    Write-Host "6. Caution! - Delete Personal Folders (Downloads, Documents, etc.)"
    Write-Host "7. Caution! - Uninstall Installed Software (select manually)"
	Write-Host "8. Toggle Seconds In Taskbar Clock"
    Write-Host "0. Exit`n"
}
function Run-UserLaptopInfo {
	Clear-Host
    Write-Host "================================="
	Write-Host "1. USER & LAPTOP INFO SCRIPT v1.0" -ForegroundColor Cyan
	Write-Host "================================="
	# Display script information
	Write-Host "DISPLAY USER AND LAPTOP DETAILS - This script will display details of USER (ID and full name) and LAPTOP (hostname, model, serial number, and IP address). Then performing ping test to Azure AD (10.32.240.20)."
	Write-Host ""
	$confirm = Read-Host "Type YES to confirm and proceed, or NO to return to menu"
	if ($confirm -ne "YES") {
		Write-Host "Operation cancelled by user." -ForegroundColor Red
		Start-Sleep -Seconds 1
		Clear-Host
		return  # returns to menu without exiting the whole script
	}
	Write-Host ""
	Write-Host "Start retrieving all details:"
	Write-Host ""
	# Get user ID
	$UserID = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	Write-Host "Login ID		: $UserID"
	# Get user full name
	$User = ([ADSI]"WinNT://$env:COMPUTERNAME/$env:USERNAME,user")
	$FullName = $User.FullName
	Write-Host "Full Name		: $FullName"
	# Get system details
	$HostName = $env:COMPUTERNAME
	Write-Host "Hostname		: $HostName"
	$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
	Write-Host "Model			: $Model"
	$Serial = (Get-WmiObject Win32_BIOS).SerialNumber
	Write-Host "Serial Number		: $Serial"
	# Get Ethernet IPv4 address (non-APIPA)
	$IP = Get-NetIPAddress -AddressFamily IPv4 |
		  Where-Object {
			  $_.InterfaceAlias -match "Ethernet" -and
			  $_.IPAddress -notmatch "^169\.254\." -and
			  $_.PrefixOrigin -ne "WellKnown"
		  } |
		  Select-Object -First 1 -ExpandProperty IPAddress
	Write-Host "IP Address		: $IP"
	Write-Host ""
	# Ping test to Azure server
	Write-Host "Start ping test to DNS Address (10.32.240.20)"
	Test-Connection -ComputerName 10.32.240.20 -Count 4
	Write-Host ""
	Read-Host "Press Enter to return to menu"
}
function Run-NetworkTools {
	function Show-Menu {
		Clear-Host
		Write-Host "===================================="
		Write-Host "2. NETWORK TROUBLESHOOTING TOOL v1.0" -ForegroundColor Cyan
		Write-Host "===================================="
		# Display script information
		Write-Host "NETWORK TROUBLESHOOTING TOOL - This script consist of several basic network troubleshooting tools as shown in the selection below:"
		Write-Host ""
		# Display menu selection
		Write-Host "1. Check Network Adapter Status"
		Write-Host "2. Check IP Configuration"
		Write-Host "3. Check Default Gateway"
		Write-Host "4. DNS Resolution Test"
		Write-Host "5. Ping Test (custom or 8.8.8.8)"
		Write-Host "6. Traceroute Test (custom or 8.8.8.8)"
		Write-Host "7. Perform All Maintenance Tasks (FlushDNS + RegisterDNS + ReleaseIP + RenewIP)"
		Write-Host "0. Return To Main Menu"
		Write-Host ""
	}
	do {
		Show-Menu
		$choice = Read-Host "Select an option [0-7]"
		switch ($choice) {
			"1" {
				Write-Host "`n[1] Network Adapter Status" -ForegroundColor Yellow
				Get-NetAdapter | Format-Table Name, Status, LinkSpeed, MacAddress -AutoSize
				Read-Host -Prompt "DONE! Press ENTER to return to menu"
			}
			"2" {
				Write-Host "`n[2] IP Configuration (IPv4)" -ForegroundColor Yellow
				Get-NetIPAddress -AddressFamily IPv4 | Format-Table InterfaceAlias, IPAddress, PrefixLength
				Read-Host -Prompt "DONE! Press ENTER to return to menu"
			}
			"3" {
				Write-Host "`n[3] Default Gateway" -ForegroundColor Yellow
				Write-Host ""
				$gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1 -ExpandProperty NextHop
				if ($gateway) {
					Write-Host "Default Gateway: $gateway"
					Write-Host ""
					Read-Host -Prompt "DONE! Press ENTER to return to menu"
				} else {
					Write-Host "No default gateway found!" -ForegroundColor Red
					Write-Host ""
					Read-Host -Prompt "Press ENTER to return to menu"
				}
			}
			"4" {
				Write-Host "`n[4] DNS Resolution Test (google.com)" -ForegroundColor Yellow
				Write-Host ""
				try {
					$resolved = Resolve-DnsName google.com -ErrorAction Stop
					Write-Host "Resolved IP(s):" -ForegroundColor Green
					$resolved.IPAddress
					Write-Host ""
					Read-Host -Prompt "DONE! Press ENTER to return to menu"
				} catch {
					Write-Host "DNS resolution failed!" -ForegroundColor Red
					Write-Host ""
					Read-Host -Prompt "Press ENTER to return to menu"
				}
			}
			"5" {
				Write-Host "`n[5] Ping Test" -ForegroundColor Yellow
				Write-Host ""
				$target = Read-Host "Enter host/IP to ping (default: 8.8.8.8)"
				if ([string]::IsNullOrWhiteSpace($target)) { $target = "8.8.8.8" }
				Test-Connection -ComputerName $target -Count 4
				Write-Host ""
				Read-Host -Prompt "DONE! Press ENTER to return to menu"
			}
			"6" {
				Write-Host "`n[6] Traceroute" -ForegroundColor Yellow
				Write-Host ""
				$traceTarget = Read-Host "Enter host/IP for traceroute (default: 8.8.8.8)"
				if ([string]::IsNullOrWhiteSpace($traceTarget)) { $traceTarget = "8.8.8.8" }
				tracert $traceTarget
				Write-Host ""
				Read-Host -Prompt "DONE! Press ENTER to return to menu"
			}
			"7" {
				Write-Host "`n[7] Performing Full Network Reset (FlushDNS + RegisterDNS + ReleaseIP + RenewIP)..." -ForegroundColor Yellow
				Write-Host ""
				ipconfig /flushdns
				ipconfig /registerdns
				ipconfig /release
				ipconfig /renew
				Write-Host ""
				Read-Host -Prompt "DONE! Press ENTER to return to menu"
			}
			"0" { 
				Write-Host ""
				Write-Host "Returning to Main Menu..." -ForegroundColor Cyan
				$running = $false
			}
			default {
				Write-Host ""
				Write-Host "Invalid selection. Please choose between 0–7." -ForegroundColor Red
			}
		}
		if ($choice -ne "0") {
			[void][System.Console]::ReadLine()
		}
	} while ($choice -ne "0")
}
function Run-SystemTools {
	function Show-Menu {
		Clear-Host
		Write-Host "==================================="
		Write-Host "3. SYSTEM TROUBLESHOOTING TOOL v1.0" -ForegroundColor Cyan
		Write-Host "==================================="
		# Display script information
		Write-Host "SYSTEM TROUBLESHOOTING TOOL - This script consist of several basic system troubleshooting tools as shown in the selection below:"
		Write-Host ""
		# Display menu selection
		Write-Host "1. Check Basic System Overview (Uptime, Disk, CPU, RAM)"
		Write-Host "2. Selection On System Diagnostic (Incomplete)"
		Write-Host "3. Selection On Disk Tools (Incomplete)"
		Write-Host "4.  (Incomplete)"
		Write-Host "5.  (Incomplete)"
		Write-Host "6. Open Task Manager (Admin)"
		Write-Host "7. Open Event Viewer (Admin)"
		Write-Host "0. Return To Main Menu"
		Write-Host ""
	}
	do {
		Show-Menu
		$choice = Read-Host "Select an option [0-7]"
		switch ($choice) {
			"1" {
            # Uptime
            $lastBoot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $uptime = (Get-Date) - $lastBoot
            Write-Host "`n--- System Uptime ---"
            Write-Host "Uptime: $([math]::floor($uptime.TotalDays)) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
			# Disk Usage
            Write-Host "`n--- Disk Usage ---"
            Get-PSDrive -PSProvider FileSystem | Format-Table Name, `
                @{Label="Used(GB)";Expression={[math]::round($_.Used / 1GB, 2)}}, `
                @{Label="Free(GB)";Expression={[math]::round($_.Free / 1GB, 2)}}
			# CPU Usage
            Write-Host "`n--- CPU Usage ---"
            Get-CimInstance Win32_Processor | Select-Object Name, LoadPercentage | Format-Table
			# Memory Usage
            Write-Host "`n--- Memory Usage ---"
            $mem = Get-CimInstance Win32_OperatingSystem
            $total = [math]::round($mem.TotalVisibleMemorySize / 1MB, 2)
            $free = [math]::round($mem.FreePhysicalMemory / 1MB, 2)
            $used = [math]::round($total - $free, 2)
            Write-Host "Total RAM: $total GB"
            Write-Host "Used RAM:  $used GB"
            Write-Host "Free RAM:  $free GB"
            Write-Host ""
			Read-Host -Prompt "DONE! Press ENTER to return to menu"
        }
			"2" {
			}
			"3" {
			}
			"4" {
			}
			"5" {
			}
			"6" { Start-Process taskmgr }
			"7" { Start-Process eventvwr }
			"0" { 
				Write-Host ""
				Write-Host "Returning to Main Menu..." -ForegroundColor Cyan
				$running = $false
			}
			default {
				Write-Host ""
				Write-Host "Invalid selection. Please choose between 0–7." -ForegroundColor Red
			}
		}
		if ($choice -ne "0") {
			[void][System.Console]::ReadLine()
		}
	} while ($choice -ne "0")
}
function Run-DomainTools {
	function Show-Menu {
		Clear-Host
		Write-Host "==================================="
		Write-Host "3. DOMAIN TROUBLESHOOTING TOOL v1.0" -ForegroundColor Cyan
		Write-Host "==================================="
		# Display script information
		Write-Host "DOMAIN TROUBLESHOOTING TOOL - This script consist of several basic domain troubleshooting tools as shown in the selection below:"
		Write-Host ""
		# Display menu selection
		Write-Host "1. Fix Trust Relationship with Domain"
		Write-Host "2.  (Incomplete)"
		Write-Host "3.  (Incomplete)"
		Write-Host "4.  (Incomplete)"
		Write-Host "5.  (Incomplete)"
		Write-Host "0. Return To Main Menu"
		Write-Host ""
	}
	do {
		Show-Menu
		$choice = Read-Host "Select an option [0-5]"
		switch ($choice) {
			 "1" {
				Clear-Host
				Write-Host "`n⚠️  This will attempt to fix the secure channel using domain credentials." -ForegroundColor Yellow
				Write-Host "1. You MUST run this script as Administrator."
				Write-Host "2. Computer must be connected to the corporate network."
				$domainUser = Read-Host "`nEnter domain admin username (e.g. DOMAIN\\Administrator)"
				$securePass = Read-Host "Enter password" -AsSecureString
				try {
					$cred = New-Object System.Management.Automation.PSCredential($domainUser, $securePass)
					Reset-ComputerMachinePassword -Credential $cred
					Write-Host "`n✅ Trust relationship has been reset successfully. Please restart your PC." -ForegroundColor Green
				}
				catch {
					Write-Host "`n❌ Failed to reset trust relationship. Check credentials or domain connectivity." -ForegroundColor Red
				}
				Pause
			}
			"2" {
			}
			"3" {
			}
			"4" {
			}
			"5" {
			}
			"0" { 
				Write-Host ""
				Write-Host "Returning to Main Menu..." -ForegroundColor Cyan
				$running = $false
			}
			default {
				Write-Host ""
				Write-Host "Invalid selection. Please choose between 0–5." -ForegroundColor Red
			}
		}
		if ($choice -ne "0") {
			[void][System.Console]::ReadLine()
		}
	} while ($choice -ne "0")
}
function Run-DeletePersonalFolders {
	Clear-Host
	Write-Host "================================"
	Write-Host "3. DELETE FILES AND FOLDERS v1.0" -ForegroundColor Cyan
	Write-Host "================================"
	# Display script information
	Write-Host "⚠️  CAUTION!! This script will permanently delete ALL files and folders in the following locations:" -ForegroundColor Red
	Write-Host "Downloads, Documents, Pictures, Videos, Music" -ForegroundColor Yellow
	Write-Host "USE WITH EXTREME CAUTION!" -ForegroundColor Red
	Write-Host ""
	$confirm = Read-Host "Type YES to confirm and proceed, or NO to return to menu"
	if ($confirm -ne "YES") {
		Write-Host "Operation cancelled by user." -ForegroundColor Red
		Start-Sleep -Seconds 1
		Clear-Host
		return  # returns to menu without exiting the whole script
	}
	Write-Host ""
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
				"Total Freed from ${folder}: $([math]::Round($totalSize / 1MB, 2)) MB`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8

			} catch {
				$errorMsg = $_.Exception.Message
				Write-Host "❌ Error deleting contents in ${folder}: $errorMsg" -ForegroundColor Red
				"[ERROR] $folder - $errorMsg`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8
			}
		} else {
			Write-Host "⚠️ Folder not found: $folder" -ForegroundColor DarkGray
			"[NOT FOUND] $folder`r`n" | Out-File -FilePath $logFile -Append -Encoding UTF8
		}
	}
	Write-Host ""
	Write-Host "DONE! Deletion process completed. Log saved to: $logFile" -ForegroundColor Cyan
 	Write-Host ""
	Read-Host "Press Enter to return to menu"
}
function Run-DeleteUserFolders {
	Clear-Host
	Write-Host "============================"
	Write-Host "4. DELETE USERS FOLDERS v1.0" -ForegroundColor Cyan
	Write-Host "============================"
	# Display script information
	Write-Host "⚠️  This script will DELETE user folders in C:\Users EXCEPT the following:" -ForegroundColor Red
	Write-Host "    - Administrator" -ForegroundColor Yellow
	Write-Host "    - user-PC" -ForegroundColor Yellow
	Write-Host "    - itadmin" -ForegroundColor Yellow
	Write-Host ""
	$confirm = Read-Host "Type YES to confirm and proceed, or NO to return to menu"
	if ($confirm -ne "YES") {
		Write-Host "Operation cancelled by user." -ForegroundColor Red
		Start-Sleep -Seconds 1
		Clear-Host
		return  # returns to menu without exiting the whole script
	}
	Write-Host ""
	Write-Host "📁 Folders marked for deletion:" -ForegroundColor Cyan
	# Define excluded user
	$excludedUsers = @('Administrator', 'user-PC', 'itadmin')
	# Get user profile folders
	$userFolders = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $excludedUsers -notcontains $_.Name }
	# Exit if no folders found
	if ($userFolders.Count -eq 0) {
		Write-Host "No folders found for deletion." -ForegroundColor Yellow
		exit
	}
	# Display folders to be deleted
	foreach ($folder in $userFolders) {
		Write-Host " - $($folder.FullName)"
	}
	# Confirm deletion
	$confirm = Read-Host "`nType YES to confirm deletion"
	if ($confirm -ne "YES") {
		Write-Host "Aborted by user." -ForegroundColor Yellow
		exit
	}
	# Set log file path
	$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
	$logPath = "C:\Users\Public\delete_folders_log_$timestamp.txt"
	# Delete folders and log
	foreach ($folder in $userFolders) {
		$folderPath = $folder.FullName
		try {
			# Calculate folder size
			$size = (Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
			$sizeMB = "{0:N2}" -f ($size / 1MB)
			# Delete folder
			Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
			Write-Host "✅ Deleted: $folderPath ($sizeMB MB)" -ForegroundColor Green
			Add-Content -Path $logPath -Value "DELETED: ${folderPath} - ${sizeMB} MB"
		}
		catch {
			$errorMessage = $_.Exception.Message
			Write-Host "❌ Error deleting ${folderPath}: ${errorMessage}" -ForegroundColor Red
			Add-Content -Path $logPath -Value "ERROR deleting ${folderPath}: ${errorMessage}"
		}
	}
	Write-Host "`n📝 Log saved to: $logPath" -ForegroundColor Cyan
 	Write-Host ""
	Read-Host "Press Enter to return to menu"
}
function Run-UninstallSoftware {
	Clear-Host
	Write-Host "================================="
	Write-Host "5. REMOVE INSTALLED SOFTWARE v1.0" -ForegroundColor Cyan
	Write-Host "================================="
	# Display script information
	Write-Host "REMOVE INSTALLED SOFTWARE - This script will display all installed software and user need to choose which software to be uninstalled (batch)."
	Write-Host ""
	$confirm = Read-Host "Type YES to confirm and proceed, or NO to return to menu"
	if ($confirm -ne "YES") {
		Write-Host "Operation cancelled by user." -ForegroundColor Red
		Start-Sleep -Seconds 1
		Clear-Host
		return  # returns to menu without exiting the whole script
	}
	Write-Host ""
	Write-Host "Start retrieving all details:"
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
	# Run uninstall process
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
 	Write-Host ""
}
function Run-EnableDisableSeconds {
		$running = $true
	function Show-Menu {
		
		Clear-Host
		Write-Host "===================================="
		Write-Host "6. TASKBAR CLOCK SECONDS TOGGLE v1.0" -ForegroundColor Cyan
		Write-Host "===================================="
		# Display script information
		Write-Host "TOGGLE SECONDS - This script will enable or disable the seconds on the taskbar clock."
		Write-Host ""
		Write-Host "Select the option as shown below:"
		Write-Host ""
		Write-Host "1. Enable Seconds on Taskbar Clock"
		Write-Host "2. Disable Seconds on Taskbar Clock"
		Write-Host "0. Return to main menu"
		Write-Host ""
	}
	function Enable-Seconds {
		# Enabling the seconds
		Write-Host ""
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1 -Force
		Write-Host "`nDONE! For Windows 10, please restart the laptop to verify the changes.`n" -ForegroundColor Green
		Write-Host ""
		Read-Host -Prompt "Press ENTER to return to menu"
	}
	function Disable-Seconds {
		# Disabling the seconds
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 0 -Force
		Write-Host "`nDONE! For Windows 10, please restart the laptop to verify the changes.`n" -ForegroundColor Green
		Write-Host ""
		Read-Host -Prompt "Press ENTER to return to menu"
	}
	#Show the options 0/1/2
	while ($running) {
		Show-Menu
		$choice = Read-Host "Enter your choice (1/2/0)"
		switch ($choice) {
			"1" { Enable-Seconds }
			"2" { Disable-Seconds }
			"0" { 
				Write-Host ""
				Write-Host "Returning to Main Menu" -ForegroundColor Cyan
				$running = $false
			}
			default { 
				Write-Host ""
				Write-Host "Invalid option. Please choose 1, 2, or 0." -ForegroundColor Red
				Start-Sleep -Seconds 2
			}
		}
	}
}	
$runMenu = $true
do {
    Show-Menu
    $choice = Read-Host "`nEnter your choice (0-8)"
    switch ($choice) {
        "1" { Run-UserLaptopInfo }
		"2" { Run-NetworkTools }
		"3" { Run-SystemTools }
		"4" { Run-DomainTools }
        "5" { Run-DeletePersonalFolders }
        "6" { Run-DeleteUserFolders }
        "7" { Run-UninstallSoftware }
		"8" { Run-EnableDisableSeconds }
        "0" { Write-Host "Exiting the script..."; $runMenu = $false }
        default { Write-Host "Invalid selection. Try again." -ForegroundColor Yellow }
    }
} while ($runMenu)
