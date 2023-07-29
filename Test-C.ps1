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

# Usage example:
$domain = "part.local"
$username = "mahdi.najafzadeh"
$password = "???"

$isValidCredential = Test-Credentials -Domain $domain -Username $username -Password $password

# Check the result
if ($isValidCredential) {
    Write-Host "Credentials are valid."
} else {
    Write-Host "Invalid credentials. Please check the username, password, and domain."
}