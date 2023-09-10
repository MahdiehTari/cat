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


 $TargetComputerName



# Create a remote session and run the script block to retrieve performance data
Invoke-Command -ComputerName $TargetComputerName -ScriptBlock {
		$hostFile = "C:\Windows\System32\drivers\etc\hosts"
		if (Test-Path "C:\users\hosts")
		{
			Copy-Item -Path $hostFile -Destination "C:\users\hosts"
		}
		
		$userchoose = Read-Host "1.ADD 2.DEL"
		
		if ($userchoose -eq 1)
		{
			
			$ipAddress = Read-Host "IP"
			
			# Validate the IP address format using regex
			if ($ipAddress -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")
			{
				
				$domainName = Read-Host "Domain Name"
				if ($domainName -match "^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$")
				{
					$entryToAdd = $ipAddress + "    " + $domainName
					add-Content $hostFile -Value $entryToAdd
					Get-Content $hostFile
					
				}
				else
				{
					Write-Host "Domain name is wrong"
				}
			}
			else
			{
				Write-Host "IP address is wrong"
			}
			
		}
		elseif ($userchoose -eq 2)
		{
			$chooseitem = $ipAddress + "    " + $domainName
			$content = Get-Content $hostFile | Where-Object { $_ -ne $chooseitem }
			Set-Content $hostFile $content
			Get-Content -path $hostFile | Out-String
		}
		
		{
		}
		msg * "ÝÇíá åÇÓÊ ÊÛííÑ íÏÇ ˜ÑÏ æ ÓíÓÊã ÔãÇ ÊÇ í˜ ÏÞíÞå ÏíÑ ÎÇãæÔ ãíÔæÏ"
	Restart-Computer -ComputerName $TargetComputerName -Delay 60
	}
	
	
	

