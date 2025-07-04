# Start of the script
Write-Host "CAUTION!! Reset Chrome - This script will completely remove all data in Chrome. Use with CAUTION!!"
Write-Host ""
Read-Host "Press Enter to continue..."
Write-Host ""

# Kill any Chrome processes
Stop-Process -Name "chrome" -Force

# Start resetting all Chrome data and profile
Write-Host "Start resetting all Chrome data and profile back to default."
Write-Host ""

# Remove Chrome data
$chromePath = Join-Path $env:USERPROFILE "AppData\Local\Google\Chrome"
Remove-Item -Path $chromePath -Recurse -Force

Write-Host ""
Write-Host "DONE! Press ENTER to exit."
Read-Host
