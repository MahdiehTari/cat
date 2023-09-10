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




Write-Host -ForegroundColor Yellow "Checking Files Larger Than 1Gb"


	try
	{
		
		Write-Host -ForegroundColor Yellow "Please Wait...................."
		
		#Scan Disk Files
		$ali = Invoke-Command -ComputerName $TargetComputerName { Get-ChildItem c:\ -r | where-object { $_.length -gt 1048576000 } | sort -descending -property length | select -first 10 | select FullName, @{ Name = 'SizeGB'; Expression = { $_.Length / 1GB } } }
		
		
		
		if ($ali -ne $Null)
		{
			#Save CSV Report On Local PC
			$ali | select FullName, SizeGB | Export-Csv c:\File_Report.csv -NoTypeInformation
			Write-Host -ForegroundColor Cyan "Comlpleted! List of Files That Is Larger Than 1Gb >>> C:\File_Report.csv"
		}
		else
		{
			Write-Host -ForegroundColor Cyan "Search Fininshed Without Result!"
		}
		
	}
	
	catch
	{
		Write-Warning $Error[0]
	}
	



