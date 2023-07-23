#---------------------------------------------
# Data's 
#---------------------------------------------
# Admin Data Info
$script:Username = "NAME.FAMILY"
$script:Firstname = $Username.Split(".")[0]
$script:Lastname = $Username.Split(".")[1]
$script:Credential = 0
# Target Data Info
$script:TargetUsername = "NAME.FAMILY"
$script:TargetComputername = "Undefined"
$script:TargetIP = "Undefined"
$script:TargetStatusNetwork = "Undefined"
$script:TargetStatusInternet = "Undefined"
# Menu
$script:MethodPathScriptList = @()

#---------------------------------------------
# Function's
#---------------------------------------------
function ShowArt {
    param (
        [string]$ArtName,
        [string]$ArtColor
    )
    if (!(Test-Path -Path "./Data/ASCII.ART/$($ArtName).txt")) {
        Write-Host "Error : Don't Find $($ArtName) Art Name." -ForegroundColor Red
    }
    else {
        $ArtData = Get-Content -Path "./Data/ASCII.ART/$($ArtName).txt"
        foreach ($Line in $ArtData.Split("`n")) {
            Write-Host $Line -ForegroundColor $ArtColor
        }
    }
}

function ShowProgramInfo {
    ShowArt -ArtName "createdby" -ArtColor "Green"
    ShowArt -ArtName "thanksto" -ArtColor "Red"
}

function ShowWellcome {
    ShowArt -ArtName "wellcome" -ArtColor "Magenta"
}

function ShowGoodBye {
    ShowArt -ArtName "goodbye" -ArtColor "Yellow"
}

function ShowFailedLoging {
    ShowArt -ArtName "failedloging" -ArtColor "Red"
}

function ShowSuccessLoging {
    ShowArt -ArtName "successloging" -ArtColor "Green"
}

function ClearHostTimed {
    Start-Sleep -Seconds 0
    Clear-Host
}

function Start-Loging {

    

    # Username 
    $Username = Read-Host "Username "
    if ($Username.ToLower() -eq "exit") {
        ShowGoodBye
        Exit
    }
    else {
        $script:Username = $Username
        $script:Firstname = $Username.Split(".")[0]
        $script:Lastname = $Username.Split(".")[1]
    }

    # Password
    $Password = Read-Host "$($script:Username) | Password " -MaskInput | ConvertTo-SecureString -AsPlainText -Force

    # Clear Host 
    ClearHostTimed

    # Create Credential
    try {
        $script:Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)
        ShowSuccessLoging
        return 1
    }
    catch {
        ShowFailedLoging
        Start-Loging
    }
}

function ShowWellcomeMenu {
    $CurrectHour = (Get-Date).Hour
    $MessageFilePath = "./HourMessage/Default.txt"
    switch ($true) {
         (($CurrectHour -ge 0) -and ($CurrectHour -lt 7)) { $MessageFilePath = "./Data/HourMessage/0_7.txt" }
         (($CurrectHour -ge 7) -and ($CurrectHour -lt 8)) { $MessageFilePath = "./Data/HourMessage/7_8.txt" }
         (($CurrectHour -ge 8) -and ($CurrectHour -lt 11)) { $MessageFilePath = "./Data/HourMessage/8_11.txt" }
         (($CurrectHour -ge 11) -and ($CurrectHour -lt 14)) { $MessageFilePath = "./Data/HourMessage/11_14.txt" }
         (($CurrectHour -ge 14) -and ($CurrectHour -lt 17)) { $MessageFilePath = "./Data/HourMessage/14_17.txt" }
         (($CurrectHour -ge 17) -and ($CurrectHour -lt 20)) { $MessageFilePath = "./Data/HourMessage/17_20.txt" }
         (($CurrectHour -ge 20) -and ($CurrectHour -lt 24)) { $MessageFilePath = "./Data/HourMessage/20_24.txt" }
        Default { $MessageFilePath = "./HourMessage/Default.txt" }
    }
    $MessageString = Get-Content -Path $MessageFilePath
    Write-Host $MessageString.Replace("{{Firstname}}", $script:Firstname) -ForegroundColor Yellow
    Write-Host ""
}

function ShowTargetInfo {
    if ($script:TargetUsername -ne "NAME.FAMILY") {
        # Show General Info
        Write-Host "[Tartget] Username     : $($script:TargetUsername)" -ForegroundColor Green
        Write-Host "[Tartget] Computername : $($script:TargetComputername)" -ForegroundColor Green
        # Show Status Network & Internet
        if ($script:TargetIP -ne "") {
            Write-Host "[Tartget] IPv4         : " -NoNewline -ForegroundColor Yellow
            Write-Host "$($script:TargetIP)" -ForegroundColor Green

            Write-Host "[Tartget] Network      : " -NoNewline -ForegroundColor Yellow
            if ($script:TargetStatusNetwork -eq "Online") {
                Write-Host "$($script:TargetStatusNetwork)" -ForegroundColor Green
            }
            else {
                Write-Host "$($script:TargetStatusNetwork)" -ForegroundColor Red
            }

            Write-Host "[Tartget] Internet     : " -NoNewline -ForegroundColor Yellow
            if ($script:TargetStatusInternet -eq "Online") {
                Write-Host "$($script:TargetStatusInternet)" -ForegroundColor Green
            }
            else {
                Write-Host "$($script:TargetStatusInternet)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "[Tartget] IPv4         : $($script:TargetIP)" -NoNewline -ForegroundColor Yellow
            Write-Host "$($script:TargetIP)" -ForegroundColor Blue
            Write-Host "[Tartget] Network      : $($script:TargetStatusNetwork)" -NoNewline -ForegroundColor Yellow
            Write-Host "$($script:TargetStatusNetwork)" -ForegroundColor Blue
            Write-Host "[Tartget] Internet     : $($script:TargetStatusInternet)" -NoNewline -ForegroundColor Yellow
            Write-Host "$($script:TargetStatusInternet)" -ForegroundColor Blue
        }
    }
    else {
        Write-Host "[Tartget] Not Select Target !" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function LoadMenuItem {
    $JSONString = Get-Content -Raw -Path "./Setting/Menu.json"
    $MenuGroups = ConvertFrom-Json $JSONString
    $CountMethod = 0
    
    foreach ($Group in $MenuGroups) {
        Write-Host "(*) $($Group.GroupName)"
        foreach ($Method in $Group.GroupMethods) {
            $CountMethod += 1
            Write-Host "  [$($CountMethod)] $($Method.Name)"
            $script:MethodPathScriptList += ($Method.PathScript)
        }
        Write-Host ""
    }

    return $CountMethod
}

function SelectMenuItem {
    param(
        [int]$CountItem
    )
    $ReturnValue = 0
    $RunLoop = $true
    while ($RunLoop) {

        PromptExitMessage
        $SelectedItem = (Read-Host "Enter Number Item [1 ~ $($CountItem)] ")

        if (($SelectedItem.ToLower() -eq "exit") -or ($SelectedItem.ToLower() -eq "cancel") -or ($SelectedItem.ToLower() -eq "0") -or ($SelectedItem.ToLower() -eq "clear")) {
            $ReturnValue = $false
            $RunLoop = $false
        }

        if ($null -ne ($SelectedItem -as [int])) {
            if ((($SelectedItem -as [int]) -ge 1) -and (($SelectedItem -as [int]) -le $CountItem)) {
                $ReturnValue = $SelectedItem
                $RunLoop = $false
            }
            else {
                Write-Host ""
                Write-Host "[Error] $($SelectedItem) is Not in Menu !" -ForegroundColor Red
                Write-Host ""
            }
        }
        else {
            Write-Host ""
            Write-Host "[Error] $($SelectedItem) is Not Number !" -ForegroundColor Red
            Write-Host ""
        }
    }

    return $ReturnValue

}

function PromptExitMessage {
    Write-Host "For " -NoNewline
    Write-Host "Exit" -NoNewline -ForegroundColor Blue
    Write-Host " , Type " -NoNewline
    Write-Host "Exit" -NoNewline -ForegroundColor Blue
    Write-Host " or " -NoNewline
    Write-Host "Cancel" -NoNewline -ForegroundColor Blue
    Write-Host " or " -NoNewline
    Write-Host "Clear" -NoNewline -ForegroundColor Blue
    Write-Host " or " -NoNewline
    Write-Host "0" -NoNewline -ForegroundColor Blue
    Write-Host " :)"
}

function RunSelectedItem {
    param (
        $ItemNumber
    )

    ClearHostTimed
    Write-Host "In RunSelectedItem"
    $ScriptContent = Get-Content -Path ($script:MethodPathScriptList[($ItemNumber -as [int]) - 1]) -Raw
    $ScriptBlock = [ScriptBlock]::Create($ScriptContent)
    & $ScriptBlock
    Read-Host
    ClearHostTimed
}


#---------------------------------------------
# Main Program
#---------------------------------------------
function Main {
    ShowWellcome

    $login = 1 # Start-Loging

    if ($login -eq 1) {

        ClearHostTimed

        $RunLoop = $true
        while ($RunLoop) {

            ShowWellcomeMenu

            # ShowLocalNetworkIdentify
            ShowTargetInfo

            $CountItem = LoadMenuItem
            
            $SelectedItem = SelectMenuItem -CountItem $CountItem

            if ($SelectedItem -eq $false) {
                $RunLoop = $false
            }
            else {
                RunSelectedItem -ItemNumber $SelectedItem
            }
        }
    }
}

Main