function New-SelfSignedCert{
    
    [CmdletBinding()] 
    Param ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$DNSName,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$FriendlyName,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CerOutputPath,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Cert:\CurrentUser\My","Cert:\CurrentUser\Root","Cert:\CurrentUser\CA","Cert:\CurrentUser\AuthRoot","Cert:\LocalMachine\Root","Cert:\LocalMachine\CA","Cert:\LocalMachine\AuthRoot","Cert:\LocalMachine\")] 
        [string]$StoreLocation,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [int]$ExpirationYearsInFuture,
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CertOutputPath
    )
    
    Write-Output "`r`n Cert:\CurrentUser\Root is: Trusted Root CA AND Cert:\CurrentUser\CA is: Intermediate CA `r`n"
    
    <# 
    # If using ISE can use these
    $DNSName         = "<COMPANY>.onmicrosoft.com"                       # Your DNS Host Name (A/CNAME Record or the like)
    $FriendlyName    = "PowerShell Graph API"                            # Friendly Name
    $CertOutputPath  = "C:\Certs\PowerShellGraphCert.cer"                # Where to export the certificate without the private key
    $StoreLocation   = "Cert:\CurrentUser\My" # "Cert:\LocalMachine\My"  # What cert store you want it to be in
    #>
    
    if(!($ExpirationYearsInFuture)){
        
        $ExpirationYearsInFuture = (Get-Date).AddYears(10)  # Expiration date of the new certificate if it is not supplied is 10 years.
    }


    # Splat for readability
    $CreateCertSplat = @{
        FriendlyName      = $FriendlyName
        DnsName           = $DNSName
        CertStoreLocation = $StoreLocation
        NotAfter          = $ExpirationYearsInFuture
        KeyExportPolicy   = "Exportable"
        KeySpec           = "Signature"
        Provider          = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        HashAlgorithm     = "SHA256"
    }

    # Create certificate
    $Certificate = New-SelfSignedCertificate @CreateCertSplat

    # Get certificate path
    $CertPath = Join-Path -Path $StoreLocation -ChildPath $Certificate.Thumbprint

    # Export certificate without private key
    Export-Certificate -Cert $CertPath -FilePath $CertOutputPath | Out-Null

}