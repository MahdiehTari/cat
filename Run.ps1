# Data's 

# Admin Data Info
$script:Username = "NAME.FAMILY"
$script:Firstname = $Username.Split(".")[0]
$script:Lastname = $Username.Split(".")[1]
$script:Credential = 0
# Target Data Info
$script:TargetUsername = "NAME.FAMILY"
$script:TargetComputername = "Undefined"
$script:TargetIP = "Undefined"
$script:TargetStatusNetwork = $false
$script:TargetStatusInternet = $false
# ScriptBlock's


# Method's
function ShowArt {
    param (
        [string]$ArtName,
        [string]$ArtColor
    )
    if (!(Test-Path -Path "./ASCII.ART/$($ArtName).txt")) {
        Write-Host "Error : Don't Find $($ArtName) Art Name." -ForegroundColor Red
    }
    else {
        $ArtData = Get-Content -Path "./ASCII.ART/$($ArtName).txt"
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
    Start-Sleep -Seconds 2
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


function LoadMenuItem {
    $JSONString = Get-Content -Raw -Path "./Setting/Menu.json"
    $MenuGroups = ConvertFrom-Json $JSONString
    $CountMethod = 1
    foreach ($Group in $MenuGroups) {
        Write-Host "* $($Group.GroupName)"
        foreach ($Method in $Group.GroupMethods) {
            Write-Host "  [$($CountMethod)] $($Method)"
            $CountMethod += 1
        }
        Write-Host ""
    }
}

function SeletMenuItem {
    
}

function ShowWellcomeMenu {
    $CurrectHour = (Get-Date).Hour
    $MessageFilePath = "./HourMessage/Default.txt"
    switch ($true) {
         (($CurrectHour -ge 0) -and ($CurrectHour -lt 7)) { $MessageFilePath = "./HourMessage/0_7.txt" }
         (($CurrectHour -ge 7) -and ($CurrectHour -lt 8)) { $MessageFilePath = "./HourMessage/7_8.txt" }
         (($CurrectHour -ge 8) -and ($CurrectHour -lt 11)) { $MessageFilePath = "./HourMessage/8_11.txt" }
         (($CurrectHour -ge 11) -and ($CurrectHour -lt 14)) { $MessageFilePath = "./HourMessage/11_14.txt" }
         (($CurrectHour -ge 14) -and ($CurrectHour -lt 17)) { $MessageFilePath = "./HourMessage/14_17.txt" }
         (($CurrectHour -ge 17) -and ($CurrectHour -lt 20)) { $MessageFilePath = "./HourMessage/17_20.txt" }
         (($CurrectHour -ge 20) -and ($CurrectHour -lt 24)) { $MessageFilePath = "./HourMessage/20_24.txt" }
        Default { $MessageFilePath = "./HourMessage/Default.txt" }
    }
    $MessageString = Get-Content -Path $MessageFilePath
    Write-Host $MessageString.Replace("{{Firstname}}", $script:Firstname) -ForegroundColor Yellow
}

function ShowTargetInfo {
    
}

# Main Program

function Main {
    ShowWellcome

    $login = Start-Loging

    if ($login -eq 1) {

        ClearHostTimed

        while ($true) {

            ShowWellcomeMenu

            # ShowLocalNetworkIdentify
            ShowTargentInfo

            LoadMenuItem

            break
        }
    }
}

Main