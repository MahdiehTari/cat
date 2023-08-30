#---------------------------------------------
# Data's 
#---------------------------------------------
# Organize Data Info
$script:Domain = "part.local"
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
    param(
        [switch]$Lazy
    )
    if ($Lazy) {
        Start-Sleep -Seconds 1
    }
    Clear-Host
}

function Test-Credentials {
    param (
        [string]$Domain,
        [string]$Username,
        [string]$Password
    )
    # Load the necessary .NET assembly
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    # Set up the context to connect to the domain
    $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain)
    # Try to validate the credentials
    $isValid = $context.ValidateCredentials($Username, $Password)
    # Return the result
    return $isValid
}

function Start-Loging {

    # Username 
    $Username = Read-Host "Username "
    if ($Username.ToLower() -eq "exit") {
        ShowGoodBye
        Exit
    }
    else {
        $script:Username = $Username.Trim()
        $script:Firstname = $Username.Split(".")[0]
        $script:Lastname = $Username.Split(".")[1]
    }

    # Password
    $Password = Read-Host "$($script:Username) | Password " -MaskInput

    try {
        
        # Validate User 
        if (Test-Credentials -Domain $script:Domain -Username $script:Username -Password $Password) {
            # Create Credential
            $script:Credential = New-Object System.Management.Automation.PSCredential($Username, $Password | ConvertTo-SecureString -AsPlainText -Force) 
            ClearHostTimed
            ShowSuccessLoging
            ClearHostTimed -Lazy
            return 1
        }
        else {
            ClearHostTimed
            ShowFailedLoging
            Start-Loging
        }
    }
    catch {
        ClearHostTimed
        ShowFailedLoging
        Write-Host "Error in Login  : $($_.Exception.Message)"
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
}

function ShowTargetInfo {

    LoadTargetInfo

    if ($script:TargetUsername -ne "NAME.FAMILY" -or $script:TargetUsername -ne "NAME.FAMILY".ToLower()) {
        # Show General Info
        Write-Host "[Tartget] Username     : " -NoNewline -ForegroundColor Yellow
        Write-host "$($script:TargetUsername)" -ForegroundColor Green
        Write-Host "[Tartget] Computername : " -NoNewline -ForegroundColor Yellow
        Write-host "$($script:TargetComputername)" -ForegroundColor Green
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

function LoadTargetInfo {
    try {
        $TargetInfo = (Get-Content -Path "./Setting/TargetInfo.json") | ConvertFrom-Json
        if ($null -ne $TargetInfo) {
            $script:TargetUsername = $TargetInfo.Username
            $script:Firstname = $script:TargetUsername.Split(".")[1]
            $script:Lastname = $script:TargetUsername.Split(".")[2]
            $script:TargetComputername = $TargetInfo.Computername
            $script:TargetIP = $TargetInfo.IP
            $script:TargetStatusNetwork = $TargetInfo.Network
            $script:TargetStatusInternet = $TargetInfo.Internet
        }
        else {
            Write-Host "[ERROR] : Cant Load Target Info" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[ERROR] : Cant Load Target Info : Error Message : $($_.Exception.Message)" -ForegroundColor Red        
    }
}

function LoadMenuItem {

    if (Test-Path -Path "./Scripts") {

        $Groups = Get-ChildItem "./Scripts" | Sort-Object -Property Name | Select-Object Name , FullName
        $CountMethod = 0

        foreach ($Group in $Groups) {

            $ShowNameGroup = $Group.Name.Split(".")[1]
            Write-Host "(*) $($ShowNameGroup)"
            $Scripts = Get-ChildItem $Group.FullName | Sort-Object -Property Name | Select-Object BaseName , FullName
            
            foreach ($Script in $Scripts) {
                $CountMethod += 1
                $ShowNameScript = $Script.BaseName.Split(".")[1]
                Write-Host "  [$($CountMethod)] $($ShowNameScript)"
                $script:MethodPathScriptList += ($Script.FullName)
            }
        }

        Write-Host ""
        return $CountMethod
    }
    else {
        Write-Host "[Error] Cant Load Menu Item's , Look Path $((Get-Location).Path + "\Scripts")" -ForegroundColor Red
        exit
    }
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
    & $ScriptBlock `
        -TargetUsername ($script:TargetUsername) `
        -TargetComputerName ($script:TargetComputername) `
        -TargetFirstname ($script:TargetUsername.Split(".")[0]) `
        -TargetLastname ($script:TargetUsername.Split(".")[1]) `
        -TargetIP ($script:TargetIP) `
        -TargetStatusNetwork ($script:TargetStatusNetwork) `
        -TargetStatusInternet ($script:TargetStatusInternet)  

    Write-Host "[INFO] Script Closed , Press Any Key to Back Menu ..." -ForegroundColor Yellow 
    Read-Host
    ClearHostTimed
}

function ShowUserInfo {
    Write-Host
    Write-Host "[User] Username        : " -NoNewline -ForegroundColor Yellow
    write-host " $($script:Username)" -ForegroundColor Green
    Write-Host
}


#---------------------------------------------
# Main Program
#---------------------------------------------
function Main {
    ShowWellcome

    $login = Start-Loging

    if ($login -eq 1) {

        ClearHostTimed

        $RunLoop = $true
        while ($RunLoop) {

            ShowWellcomeMenu

            ShowUserInfo
            
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