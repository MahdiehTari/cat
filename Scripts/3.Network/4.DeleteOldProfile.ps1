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







	# Prompt the user to enter the name of the computer to remove the user from
	$computer = $TargetComputerName
	
	# Use Invoke-Command to run a script block on the specified computer to get a list of unique user profiles
	$users = Invoke-Command -ComputerName $computer -ScriptBlock {
		Get-CimInstance -Class Win32_UserProfile
	} | Select-Object -ExpandProperty LocalPath -Unique | ForEach-Object { $_.Split('\')[-1] }
	
	# If no user profiles were found, notify the user and continue the loop
	if ($users.Count -eq 0)
	{
		Write-Host "No user profiles found on $computer."
		Continue
	}
	
	# If user profiles were found, display them to the user
	Write-Host "Users on $computer :"
	
	for ($i = 0; $i -lt $users.Count; $i++)
	{
		Write-Host "$($i + 1). $($users[$i])"
	}
	
	# Prompt the user to enter the number of the user they want to remove
	$userNumber = Read-Host "Enter the number of the user you want to remove"
	
	# Get the user's name based on the selected number
	$user = $users[$userNumber - 1]
	
	# Use Invoke-Command again to run a script block on the specified computer to remove the selected user's profile
	Invoke-Command -ComputerName $computer -ScriptBlock {
		param ($user)
		Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $user } | Remove-CimInstance
	} -ArgumentList $user
	
	# Notify the user that the user profile has been successfully deleted
	Write-Host "$user has been successfully deleted from $computer."
	

