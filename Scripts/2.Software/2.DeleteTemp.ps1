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







try
{
	#Create WinRM Session
	$computerName = $TargetComputerName
	
	
	
	# Create a remote session and run the script block to retrieve performance data
	Invoke-Command -ComputerName $computerName -ScriptBlock {
		Write-Host -ForegroundColor Yellow "Please Wait...................."
		
		
		#Delete Temp Files
		 Set-Location "C:\Windows\Temp" 
		 Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue 
		Set-Location "C:\Windows\Prefetch" 
		Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue 
	 Set-Location "C:\Documents and Settings" 
		 Remove-Item ".\*\Local Settings\temp\*" -Recurse -Force -ErrorAction SilentlyContinue 
		Set-Location "C:\Users" 
		 Remove-Item ".\*\Appdata\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue 
	 Set-Location "C:\Users" 
	 Remove-Item ".\*\Appdata\Local\npm-cache\*" -Recurse -Force -ErrorAction SilentlyContinue 
		
		if ($Error[0] -ne $null)
		{
			Write-Host -ForegroundColor Cyan "Clean up has Successfully Completed"
		}
		
		
	}
}

catch
{
	Write-Warning $Error[0]
}



