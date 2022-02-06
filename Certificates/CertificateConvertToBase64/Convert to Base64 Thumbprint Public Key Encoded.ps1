function Convert-CertToBase64{
    
    [CmdletBinding()] 
    Param ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CertName
    )
    # Convert to Base64 Thumbprint Public Key Encoded

    #$CertName = "C:\Temp\Cert.cer" # A PFX will have the Private key a CER won't.

    $cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cer.Import($CertName)
    $bin = $cer.GetRawCertData()
    $base64Value = [System.Convert]::ToBase64String($bin)
    $bin = $cer.GetCertHash()
    $base64Thumbprint = [System.Convert]::ToBase64String($bin)
    $keyid = [System.Guid]::NewGuid().ToString()

    # Save These:
    Write-Output "`r`n`$base64Thumbprint is: $($base64Thumbprint)"
    Write-Output "`$base64Value is: $($base64Value)"
    Write-Output "`$keyid is: $($keyid) `r`n"

    Write-Output "The export has not been tested"
    $base64Value | Out-File ((Split-Path -Filepath $CertName -Parent)+"_Base64.cer")
}