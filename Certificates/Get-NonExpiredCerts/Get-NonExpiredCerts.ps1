function Get-NonExpiredCerts{
    
    [CmdletBinding()] 
    Param ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CA
    )
    
    # Get Non-Expired Certs from a CA

    if(!($CA)){
        $CA = ($env:COMPUTERNAME)
    }
    
    if(Get-Module -ListAvailable -Name PSPKI -eq $null){
        Install-Module -Name PSPKI -Scope CurrentUser
    }
    Import-Module -Name PSPKI

    #Get-IssuedRequest -Property CertificateTemplate | ? { $_.CertificateTemplate -eq "The Certificate Template Value From Above Command" }

    Get-CertificationAuthority -Computername $CA | Get-IssuedRequest -Property * | 
    Where-Object {$_.NotAfter -lt (Get-Date).AddDays(1)} | Select-Object Notbefore,NotAfter,CertificateHash,SubjectKeyIdentifier,CertificateTemplate,Request.CommonName,Request.DistinguishedName,PublicKeyAlgorithm,PublicKeyLength,Request.RequesterName | 
    Export-CSV "C:\Temp\$($CA)_NonExpiredCerts.csv"

}