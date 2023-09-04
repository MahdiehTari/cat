param(
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








# Prompt the user for the computer name
$computerName = $TargetComputerName



# Create a remote session and run the script block to retrieve performance data
Invoke-Command -ComputerName $computerName -ScriptBlock {
	# Get the total amount of memory installed on the system
	$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
	
	
		# Get the current date and time
		$date = Get-Date -Format "yyyy-MM-dd"
		
		# Separator
		$separator = "-" * 80
		
		# Heading
		Write-Host "`nPerformance Data for $env:COMPUTERNAME at $date`n$separator`n" -ForegroundColor Green
		
		# Get the CPU usage percentage
		$cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
		
		# Get the top 10 processes consuming CPU and RAM
		$processesByCPU = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -Property ProcessName, CPU -First 10
		$processesByMemory = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -Property ProcessName, WorkingSet -First 10
		
		# Get the available memory and calculate as a percentage of the total system RAM
		$availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
		$availMemPercent = (104857600 * $availMem / $totalRam)
		
		# CPU usage table
		$cpuTable = $processesByCPU | Format-Table -Property @{ Label = "Process Name"; Expression = { $_.ProcessName } }, @{ Label = "CPU Usage (%)"; Expression = { ('{0:0.0} %' -f $_.CPU) } } -AutoSize | Out-String
		
		# Memory usage table
		$memoryTable = $processesByMemory | Format-Table -Property @{ Label = "Process Name"; Expression = { $_.ProcessName } }, @{ Label = "Memory Usage (KB)"; Expression = { ($_.WorkingSet/1KB) } }, @{ Label = "Memory Usage (%)"; Expression = { ('{0:0.0} %' -f (100 * ($_.WorkingSet)/$totalRam)) } } -AutoSize | Out-String
		
		# Performance data table
		$perfTable = @{
			'CPU Usage (%)'  = ('{0:0.000} %' -f $cpuTime)
			'Available Memory (MB)' = $availMem.ToString("N0")
			'Memory Available (%)' = ('{0:0.0} %' -f $availMemPercent)
		} | Format-Table -AutoSize | Out-String
		
		# Output the tables to the console with formatting
		Write-Host "`nCPU Usage:`n" -ForegroundColor Cyan
		Write-Host $cpuTable
		Write-Host "`nTop 10 Processes by Memory Usage:`n" -ForegroundColor Cyan
		Write-Host $memoryTable
		Write-Host "`nPerformance Data:`n" -ForegroundColor Cyan
		Write-Host $perfTable
		
		# Wait for 6 seconds before refreshing
		
	}
