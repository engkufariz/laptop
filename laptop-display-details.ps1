# Display script information
Write-Host "DISPLAY USER AND LAPTOP DETAILS - This script will display details of USER (ID and full name) and LAPTOP (hostname, model, serial number, and IP address). Then performing ping test to Azure AD (10.32.240.20)"
Write-Host ""
Read-Host "Press Enter to continue"
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

# Get the primary non-APIPA IP address
$IP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch "^169\.254\." } | Select-Object -First 1).IPAddress
Write-Host "IP Address		: $IP"
Write-Host ""
# Ping test to Azure server
Write-Host "Start ping test to DNS Address (10.32.240.20)"
Test-Connection -ComputerName 10.32.240.20 -Count 4
Write-Host ""
Read-Host "Press Enter to exit"