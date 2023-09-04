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

$computerName = $TargetComputerName




Invoke-Command -ComputerName $computerName -ScriptBlock {
	
	$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
	foreach ($obj in $InstalledSoftware) { write-host $obj.GetValue('DisplayName') -NoNewline; write-host "- " -NoNewline; write-host $obj.GetValue('DisplayVersion') }
}