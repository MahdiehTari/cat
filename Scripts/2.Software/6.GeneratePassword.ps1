function Generate-RandomPassword {
    $lowercaseChars = "abcdefghijklmnpqrstuvwxyz"
    $digitChars = "123456789"
    $symbolChars = "$%#@"
    
    $password = ""
    
    # Add one character from each category
    $password += $lowercaseChars[(Get-Random -Minimum 0 -Maximum $lowercaseChars.Length)]
    $password += $digitChars[(Get-Random -Minimum 0 -Maximum $digitChars.Length)]
    $password += $symbolChars[(Get-Random -Minimum 0 -Maximum $symbolChars.Length)]
    
    # Fill the rest of the password with random characters
    $remainingLength = 8 - $password.Length
    for ($i = 0; $i -lt $remainingLength; $i++) {
        $randomCharSet = $lowercaseChars + $digitChars + $symbolChars
        $password += $randomCharSet[(Get-Random -Minimum 0 -Maximum $randomCharSet.Length)]
    }
    
    # Shuffle the characters in the password
    $shuffledPassword = -join ($password.ToCharArray() | Get-Random -Count $password.Length)
    
    return $shuffledPassword
}

$randomPassword = Generate-RandomPassword

Write-Host "Your Random Password Successfully Generated and Copied to Clipboard:"
Write-Host $randomPassword -ForegroundColor Green
Write-Host ""
# Copy the password to clipboard
$randomPassword | Set-Clipboard

# Wait for 5 seconds
Start-Sleep -Seconds 4