
param (
	[string]$TargetUsername,
	[string]$TargetComputerName,
	[string]$TargetFirstname,
	[string]$TargetLastname,
	[string]$TargetIP,
	[string]$TargetStatusNetwork,
	[string]$TargetStatusInternet
)

Write-Host $TargetUsername
Write-Host $TargetComputerName
Write-Host $TargetFirstname
Write-Host $TargetLastname
Write-Host $TargetIP
Write-Host $TargetStatusNetwork
Write-Host $TargetStatusInternet






Write-Host "===================== Disk Information: =====================" -ForegroundColor Red

Get-CimInstance -Class win32_logicaldisk -ComputerName $TargetComputerName |
Where-Object { $_.DriveType -ne 4 } | # exclude network drives (DriveType 4)
Format-Table DeviceID, @{ Name = "Free Disk Space (GB)"; e = { [math]::Round($_.FreeSpace /1GB) } }, @{ Name = "Total Disk Size (GB)"; e = { [math]::Round($_.Size /1GB) } } -AutoSize