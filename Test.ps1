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

CreateTemplateTargetFile -Path "./Setting/TargetInfo.json"