

    $name = Read-Host "Computer or username"
    $wild = "*$name*"
    $cmp = Get-ADComputer -Filter "Name -Like '$wild'" -Properties * | Select-Object Name, Description, IPv4Address, OperatingSystem, OperatingSystemVersion, ms-Mcs-AdmPwd, Canonicalname, PreventiveMaintenance
    $usr = Get-ADComputer -Filter "Description -Like '$wild'" -Properties * | Select-Object Name, Description, IPv4Address, OperatingSystem, OperatingSystemVersion, ms-Mcs-AdmPwd, Canonicalname, PreventiveMaintenance   
    if ($cmp) {
            $crrusr = Invoke-Command -ComputerName $cmp.name -ScriptBlock {(Get-WMIObject -ClassName Win32_ComputerSystem).Username}
            $cmp
            $crrusr
    }
    else {
        $usr
    }
