$ColorTextData = @{
    PromptError       = @{
        Text       = "[ERROR] : Enter a Valid Type of Identifier. Example : Username , ComputerName , IPv4"
        ConfigText = "11,Yellow|13,Yellow|15,Yellow"
    }
    PromptHelpExit    = @{
        Text       = "[HELP] : For Exit , Type Exit or Cancel or Clear or 0 :)"
        ConfigText = "4,Red|7,Blue|9,Blue|11,Blue|13,Blue"
    }
    PromptInputTarget = @{
        Text       = "[INPUT] : Enter ( Username or Computername or IPv4 )"
        ConfigText = "5,Yellow|7,Yellow|9,Yellow"
    }
    PromptAccept      = @{
        Text       = "[INPUT] : Are You Accept this Traget ? ( Accept : 'Yes' or 'Y' , Test & Accept : 'Test' or 'YT' , Don't Accept : 'No' or 'N' )"
        ConfigText = "5,Blue|7,Yellow|10,Green|12,Green|14,Green|16,Blue|17,Blue|18,Blue|20,Blue|22,Blue|24,Red|25,Red|27,Red|29,Red"
    }
}
 
function MakeColorPrompt {
    param (
        [string]$Text,
        [string]$ConfigText,
        [switch]$NoNewLine
    )
    #
    if (($null -ne $Text ) -and ($null -ne $ConfigText)) {
        $TextArray = $Text.Split(" ")
        $ConfigTextArray = $ConfigText.Split("|")
        for ($Tindex = 0 ; $Tindex -lt $TextArray.Length ; $Tindex += 1) {
            $Color = "Gray"
            for ($Cindex = 0 ; $Cindex -lt $ConfigTextArray.Length ; $Cindex += 1) {
                $ConfigWord = $ConfigTextArray[$Cindex].Split(",")
                if (($Tindex + 1) -eq $ConfigWord[0]) {
                    $Color = $ConfigWord[1]
                    break
                }
            }   
            if ($Tindex -eq ($TextArray.Length - 1)) {
                if ($NoNewLine) {
                    Write-Host "$($TextArray[$Tindex])" -ForegroundColor $Color -NoNewline
                }
                else {
                    Write-Host "$($TextArray[$Tindex])" -ForegroundColor $Color
                }
            }
            else {
                Write-Host "$($TextArray[$Tindex]) " -ForegroundColor $Color -NoNewline
            }
        }
    }    
}

function CreateTemplateTargetFile {
    param(
        [string]$Path
    )

    $TemplateTargetInfo = @{
        Username     = "NAME.FAMILY"
        ComputerName = "Undefined"
        IP           = "Undefined"
        Network      = "Offline"
        Internet     = "Offline"
    }

    Write-Host "[INFO] : Create File at '$($Path)' For Save Target Info ..." -ForegroundColor Yellow
    try {
        New-Item -Path $Path -ItemType File -Value ($TemplateTargetInfo | ConvertTo-Json) -Force | Out-Null
        Write-Host "[SUCCESS] : Created TargetInfo File." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] : Can't Create Target Info File : $($_.Exception.Message)"
        exit
    }
} 

    
    
$TargetInfoFilePath = "$((Get-Location).Path)\Setting\TargetInfo.json"

if (Test-Path -Path $TargetInfoFilePath) {
    try {
        $TargetInfo = (Get-Content -Path $TargetInfoFilePath) | ConvertFrom-Json
    }
    catch {
        Write-Host "[ERROR] : Cant Convert JSON file to Object , Error Message : $($_.Exception.Message)" -ForegroundColor Red
        CreateTemplateTargetFile -Path $TargetInfoFilePath 
    }
}
else {
    Write-Host "[ERROR] : Can't Find '$($TargetInfoFilePath)' File." -ForegroundColor Red
    CreateTemplateTargetFile -Path $TargetInfoFilePath
}


if ($null -ne $TargetInfo) {
    Write-Host ""
    Write-Host "Target Username     : $($TargetInfo.Username)"
    Write-Host "Target ComputerName : $($TargetInfo.ComputerName)"
    Write-Host "Target IP           : $($TargetInfo.IP)"
    Write-Host "Target Network      : $($TargetInfo.Network)"
    Write-Host "Target Internet     : $($TargetInfo.Internet)"
}


$RunLoop = $true
while ($RunLoop) {

    Write-Host ""
    MakeColorPrompt -Text $ColorTextData.PromptHelpExit.Text -ConfigText $ColorTextData.PromptHelpExit.ConfigText
    MakeColorPrompt -Text $ColorTextData.PromptInputTarget.Text -ConfigText $ColorTextData.PromptInputTarget.ConfigText -NoNewLine
    $Identifier = Read-Host " "
    Write-Host ""

    switch ($true) {


        ($Identifier -match "(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}") {
            Write-Host "Target IP : $($Identifier)"

            $RunLoop = $false
            break
        }


        ($Identifier -match "\w\.\w") {

            
            Write-Host "[INFO] : Target Username : $($Identifier)"
            Write-Host "[INFO] : Sreach Useranme ..." -ForegroundColor Yellow

            try {
                $TargetData = Get-ADComputer -Filter "Description -Like '*$($Identifier)*'" -Properties * | Select-Object Description , Name , IPv4Address
            }
            catch {
                Write-Host "[ERROR] : Script Crashed : $($_.Exception.Message)" -ForegroundColor Red
            }

            if ($null -ne $TargetData) {
                
                if ($TargetData.Length -eq 1) {

                    Write-Host "[SUCCESS] : Target Found ! Username : $($TargetData.Description) , Computername : $($TargetData.Name) , IPv4 : $($TargetData.IPv4Address)" -ForegroundColor Green

                    MakeColorPrompt -Text $ColorTextData.PromptAccept.Text -ConfigText $ColorTextData.PromptAccept.ConfigText -NoNewLine
                    $ResponseAccept = Read-Host " "

                    if (($ResponseAccept.ToLower() -eq "test") -or ($ResponseAccept.ToLower() -eq "yt")) {

                        Write-Host "[INFO]    : Accepted Target !" -ForegroundColor Yellow
                        Write-Host "[INFO]    : $($TargetData.Name) Network Testing ..." -ForegroundColor Yellow
                        if (Test-Connection -ComputerName $TargetData.Name -Quiet) {
                            Write-Host "[SUCCESS] : Target is Online Now !" -ForegroundColor Green
                            $TargetInfo.Network = "Online"
                        }
                        else {
                            Write-Host "[FAILED]  : Target is Offline Now !" -ForegroundColor Red
                            $TargetInfo.Network = "Offline"    
                        }
                        #
                        if ($null -ne $TargetData.Description) {
                            $TargetInfo.Username = $TargetData.Description
                        }
                        else {
                            $TargetInfo.Username = "NAME.FAMILY"
                        }
                        #
                        if ($null -ne $TargetData.Name) {
                            $TargetInfo.ComputerName = $TargetData.Name
                        }
                        else {
                            $TargetInfo.ComputerName = "Undefined"
                        }
                        #
                        if ($null -ne $TargetData.IPv4Address) {
                            $TargetInfo.IP = $TargetData.IPv4Address
                        }
                        else {
                            $TargetInfo.IP = "Undefined"
                        }
                    }
                    elseif (($ResponseAccept.ToLower() -eq "yes") -or ($ResponseAccept.ToLower() -eq "y")) {
                        Write-Host "[INFO]    : Accepted Target !" -ForegroundColor Yellow
                        
                        if ($null -ne $TargetData.Description) {
                            $TargetInfo.Username = $TargetData.Description
                        }
                        else {
                            $TargetInfo.Username = "NAME.FAMILY"
                        }

                        if ($null -ne $TargetData.Name) {
                            $TargetInfo.ComputerName = $TargetData.Name
                        }
                        else {
                            $TargetInfo.ComputerName = "Undefined"
                        }

                        if ($null -ne $TargetData.IPv4Address) {
                            $TargetInfo.IP = $TargetData.IPv4Address
                        }
                        else {
                            $TargetInfo.IP = "Undefined"
                        }
                    }
                    else {
                        Write-Host "[INFO]    : Don't Accepted Target !" -ForegroundColor Yellow
                        continue
                    }

                }
                else {
                    Write-Host "[INFO] : Find $($TargetData.Length) Username Like Your Input" -ForegroundColor Yellow

                    Write-Host
                    for ($index = 0; $index -lt $TargetData.Length; $index += 1) {
                        Write-Host "[$($index + 1)] Username : $($TargetData[$index].Description) , Computername : $($TargetData[$index].Name) , IPv4 : $($TargetData[$index].IPv4Address)"
                    }
                    Write-Host

                    Write-Host "[HELP] : Select Currect Target From List !"
                    MakeColorPrompt -Text $ColorTextData.PromptHelpExit.Text -ConfigText $ColorTextData.PromptHelpExit.ConfigText
                    $RunLoop1 = $true
                    while ($RunLoop1) {
                        Write-Host "[INPUT] : Enter Target Number " -NoNewline
                        $TargetSelectedNumber = Read-Host " "
                        if ($null -ne ($TargetSelectedNumber -as [int])) {
    
                            if ((($TargetSelectedNumber -as [int]) -gt 0) -and (($TargetSelectedNumber -as [int]) -le $TargetData.Length)) {
                                
                                $TargetDataSelected = $TargetData[($TargetSelectedNumber -as [int]) - 1]

                                Write-Host "[SUCCESS] : Selected $($TargetSelectedNumber -as [int])) , Username : $($TargetDataSelected.Description) , Computername : $($TargetDataSelected.Name) , IPv4 : $($TargetDataSelected.IPv4Address)" -ForegroundColor Green


                                MakeColorPrompt -Text $ColorTextData.PromptAccept.Text -ConfigText $ColorTextData.PromptAccept.ConfigText -NoNewLine
                                $ResponseAccept = Read-Host " "
            
                                if (($ResponseAccept.ToLower() -eq "test") -or ($ResponseAccept.ToLower() -eq "yt")) {
            
                                    Write-Host "[INFO]    : Accepted Target !" -ForegroundColor Yellow
                                    Write-Host "[INFO]    : $($TargetDataSelected.Name) Network Testing ..." -ForegroundColor Yellow
                                    if (Test-Connection -ComputerName $TargetDataSelected.Name -Quiet) {
                                        Write-Host "[SUCCESS] : Target is Online Now !" -ForegroundColor Green
                                        $TargetInfo.Network = "Online"
                                    }
                                    else {
                                        Write-Host "[FAILED]  : Target is Offline Now !" -ForegroundColor Red
                                        $TargetInfo.Network = "Offline"    
                                    }
                                    #
                                    if ($null -ne $TargetDataSelected.Description) {
                                        $TargetInfo.Username = $TargetDataSelected.Description
                                    }
                                    else {
                                        $TargetInfo.Username = "NAME.FAMILY"
                                    }
                                    #
                                    if ($null -ne $TargetDataSelected.Name) {
                                        $TargetInfo.ComputerName = $TargetDataSelected.Name
                                    }
                                    else {
                                        $TargetInfo.ComputerName = "Undefined"
                                    }
                                    #
                                    if ($null -ne $TargetDataSelected.IPv4Address) {
                                        $TargetInfo.IP = $TargetDataSelected.IPv4Address
                                    }
                                    else {
                                        $TargetInfo.IP = "Undefined"
                                    }
                                }
                                elseif (($ResponseAccept.ToLower() -eq "yes") -or ($ResponseAccept.ToLower() -eq "y")) {
                                    Write-Host "[INFO]    : Accepted Target !" -ForegroundColor Yellow
                                    
                                    if ($null -ne $TargetDataSelected.Description) {
                                        $TargetInfo.Username = $TargetDataSelected.Description
                                    }
                                    else {
                                        $TargetInfo.Username = "NAME.FAMILY"
                                    }
            
                                    if ($null -ne $TargetDataSelected.Name) {
                                        $TargetInfo.ComputerName = $TargetDataSelected.Name
                                    }
                                    else {
                                        $TargetInfo.ComputerName = "Undefined"
                                    }
            
                                    if ($null -ne $TargetDataSelected.IPv4Address) {
                                        $TargetInfo.IP = $TargetDataSelected.IPv4Address
                                    }
                                    else {
                                        $TargetInfo.IP = "Undefined"
                                    }
                                }
                                else {
                                    Write-Host "[INFO]    : Don't Accepted Target !" -ForegroundColor Yellow
                                    $RunLoop1 = $false
                                }
                            }
                        }
                    }
                }
            }
            else {
                Write-Host "[ERROR]   : Can't Find this Username" -ForegroundColor Red
                break
            }

            $RunLoop = $false
            break
            
        }


        ($Identifier -match "[W,M,L]-P[0,3,5]-\w+\d+") {
            Write-Host "Target Computername : $($Identifier)"
            $RunLoop = $false
            break
        }


        (($Identifier.ToLower() -eq "exit") -or ($Identifier.ToLower() -eq "cancel") -or ($Identifier.ToLower() -eq "clear") -or ($Identifier.ToLower() -eq "0")) {
            Write-Host "[Warning] Dont Change Target Info !" -ForegroundColor Yellow
            $RunLoop = $false
            break
        }


        Default {
            MakeColorPrompt -Text $ColorTextData.PromptError.Text -ConfigText $ColorTextData.PromptError.ConfigText
        }
    }
}

try {
    Set-Content -Path $TargetInfoFilePath -Value ($TargetInfo | ConvertTo-Json)
    Write-Host "[SUCCESS] : Target Data Saved !" -ForegroundColor Green
}
catch {
    Write-Host "[FAILED]  : Target Data Not Saved : $($_.Exception.Message)" -ForegroundColor Red  
}

Write-Host ""