param(
    [string]$Commit
)

if ($null -ne $Commit) {
    git init
    git add -A
    git commit -m "$($Commit)"
    git remote add origin git@gitlab.partdp.ir:network/local-network/local-support-automation/cat.git
    git push -u -f origin main
}
else {
    Write-Host "Add Commit Parameter !!!" -ForegroundColor Red
}
