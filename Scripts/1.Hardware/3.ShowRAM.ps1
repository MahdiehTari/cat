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



Write-Host "===================== Memory Information: =====================" -ForegroundColor Red

$PhysicalMemory = Get-CimInstance -Class "win32_physicalmemory" -Namespace "root\CIMV2" -ComputerName $TargetComputerName

if ($PhysicalMemory.SMBiosMemoryType -eq "26")
{
	Write-Host "It's DDR4 Memory" -ForegroundColor Yellow
}

$PhysicalMemory | Format-Table Tag, BankLabel, @{
	n  = "Capacity (GB)"
	e  = { $_.Capacity / 1GB }
},
							   Manufacturer, Speed, FormFactor, SMBiosMemoryType, PartNumber -AutoSize

Write-Host "Total Memory:" -ForegroundColor White
Write-Host "$((($PhysicalMemory).Capacity | Measure-Object -Sum).Sum/1GB)" -ForegroundColor Green

$TotalSlots = ((Get-CimInstance -Class "win32_PhysicalMemoryArray" -Namespace "root\CIMV2" -ComputerName $TargetComputerName).MemoryDevices | Measure-Object -Sum).Sum

Write-Host "`nTotal Memory Slots:" -ForegroundColor White
Write-Host $TotalSlots -ForegroundColor Green

$UsedSlots = (($PhysicalMemory) | Measure-Object).Count

Write-Host "`nUsed Memory Slots:" -ForegroundColor White
Write-Host $UsedSlots -ForegroundColor Green

if ($UsedSlots -eq $TotalSlots)
{
	Write-Host "All memory slots are filled up, none is empty!" -ForegroundColor Yellow
}