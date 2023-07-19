$JSONString = Get-Content -Raw -Path "./Setting/Menu.json"
$MenuGroups = ConvertFrom-Json $JSONString
$CountMethod = 1
$Script:MethodPathScriptList = @()

foreach ($Group in $MenuGroups) {
    Write-Host "(*) $($Group.GroupName)"
    foreach ($Method in $Group.GroupMethods) {
        Write-Host "  [$($CountMethod)] $($Method.Name)"
        $CountMethod += 1
        $MethodPathScriptList += ($Method.PathScript)
        New-Item -Path $Method.PathScript -ItemType File
    }
    Write-Host ""
}