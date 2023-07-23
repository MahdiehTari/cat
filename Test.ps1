function PromptMessage {
    Write-Host "For " -NoNewline
    Write-Host "Exit" -NoNewline -ForegroundColor Blue
    Write-Host " , Type " -NoNewline
    Write-Host "Exit" -NoNewline -ForegroundColor Blue
    Write-Host " or " -NoNewline
    Write-Host "Cancel" -NoNewline -ForegroundColor Blue
    Write-Host " :)"
}

function PromptError {
    Write-Host "Enter a Valid Type of Identifier. Example : " -NoNewline
    Write-Host "Username" -NoNewline -ForegroundColor Yellow
    Write-Host " , " -NoNewline
    Write-Host "ComputerName" -NoNewline -ForegroundColor Yellow
    Write-Host " , " -NoNewline
    Write-Host "IPv4" -NoNewline -ForegroundColor Yellow
    Write-Host ""
}

function Prompt  {
    param (
        OptionalParameters
    )
    
}

# $TargetInfoFilePath = ".\Setting\TargetInfo.csv"

$TargetInfo = Import-Csv -Path ".\Setting\TargetInfo.csv" -Delimiter ","



if ($null -ne $TargetInfo) {
    Write-Host ""
    Write-Host "Target Username : $($TargetInfo.Username)"
    Write-Host "Target ComputerName : $($TargetInfo.ComputerName)"
    Write-Host "Target IP : $($TargetInfo.IP)"
    Write-Host "Target Network : $($TargetInfo.Network)"
    Write-Host "Target Internet : $($TargetInfo.Internet)"
    Write-Host ""
}


# Prompt Message
PromptMessage

$Identifier = Read-Host "Enter (Username or Computername or IPv4) "

$RunLoop = $true
while ($RunLoop) {
    switch ($true) {
        ($Identifier -match "\w+\.\w+") {
            Write-Host "Target Username : $($Identifier)"
            Write-Host "[INFO] : Sreach Useranme ..." -ForegroundColor Yellow

            $TargetData = Get-ADComputer -Filter "Description -Like '$($Identifier)'" -Properties * | Select-Object Description , Name , IPv4Address

            if ($null -ne $TargetData) {
                
                if ($TargetData.Length -eq 1) {

                    Write-Host "[SUCCESS] : Target Found ! Username : $($TargetData.Description) , Computername : $($TargetData.Name) , IPv4 : $($TargetData.IPv4Address)" -ForegroundColor Green



                    if ($null -ne $TargetData.Name) {
                        $TargetInfo.ComputerName = $TargetData.Name
                    }
                    else {
                        $TargetInfo.ComputerName = "Undefined"
                    }

                    if ($null -ne $TargetData.IPv4Address) {
                        $TargetInfo.IPv4 = $TargetData.IPv4Address
                    }
                    else {
                        $TargetInfo.IPv4 = "Undefined"
                    }
                }
                else {
                    
                }
            }
            else {
                Write-Host "[Error]"
            }

            $RunLoop = $false
            break
        }
        ($Identifier -match "(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}") {
            Write-Host "Target IP : $($Identifier)"
        }
        ($Identifier -match "[W,M,L]-P[0,3,5]-\w+\d+") {
            Write-Host "Target Computername : $($Identifier)"
            $RunLoop = $false
            break
        }
        (($Identifier.ToLower() -eq "exit") -or ($Identifier.ToLower() -eq "cancel")) {
            Write-Host "[Warning] Dont Change Target Info !" -ForegroundColor Yellow
            $RunLoop = $false
            break
        }
        Default {
            Write-Host ""
            PromptError
            PromptMessage
            Write-Host ""
            $Identifier = Read-Host "Enter (Username or Computername or IPv4) "
            Write-Host ""
        }
    }
}

Export-Csv -Path ".\Setting\TargetInfo.csv" -InputObject $TargetInfo -NoTypeInformation