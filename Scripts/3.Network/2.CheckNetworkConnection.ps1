

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



$NetworkState

$NetworkState = Start-Job -Name testNet -ScriptBlock {
	
	$TestLocalNetwork = @(Test-NetConnection -computername 192.168.1.46 -InformationLevel Quiet)
	$TestInternet = @(Test-NetConnection -computername 8.8.8.8 -InformationLevel Quiet)
	if ($TestLocalNetwork -and $TestInternet)
	{
		[Environment]::SetEnvironmentVariable("Network", "PassNetwork", "Machine")
		
	}
	
	else
	{
		
		$ipAddress = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Preferred" }).IPAddress
		$InvalidIpAddress = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Tentative" }).InterfaceAlias
		
		[Environment]::SetEnvironmentVariable("Network", $ipAddress, "Machine")
		
		if ($ipAddress -eq "10.10.144.88")
		{
			
			msg * "VPN is On ! Please Turn Off it."
		}
		
		if (!$TestInternet -and !$TestLocalNetwork)
		{
			
			[Environment]::SetEnvironmentVariable("Network", "Do it", "Machine")
			
			Disable-NetAdapter -Name $InvalidIpAddress -Confirm:$false
			
			Enable-NetAdapter -Name $InvalidIpAddress -Confirm:$false
			
		}
		
		if (!$TestInternet)
		{
			
			msg * "Please Login to Kerio!"
		}
		
	}
	Start-Sleep -Seconds 1800
	
	
	
}

