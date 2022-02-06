function RootCA-CRL-Publish{
    
    [CmdletBinding()] 
    Param ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$SubCAs, 

        [Parameter(Mandatory=$false)] 
        [ValidateNotNullOrEmpty()] 
        [string]$ExPath
    ) 

    # Publish CRL
    certutil -crl 

    # These are usefull if you are running this script in the ISE/Interactively
    #$SubCAs = @('PROD-CERT02-AKL', 'PROD-CERT02-LON') 
    #$ExPath = 'C:\Windows\System32\CertSrv\CertEnroll'  # This should not be in the default path for security and BPA reasons.

    Invoke-Command -ComputerName $SubCAs -ArgumentList $exPath -ScriptBlock {
        
        Write-Verbose "Looking for included *.crl.." -Verbose
        
        
        $crlFile = Get-Childitem $exPath | Where-Object {$_.Extension -match "crl"}
        $crlFile

        if ($null -ne $crlFile) {
            # Loop Through Multiple Files
            foreach ($CRL in $crlFile)
            {
                Write-Verbose "Discovered a .cer as part of the Service, installing it in the LocalMachine\Root certificate store..." -Verbose
                certutil -addstore Root $CRL.FullName   # Add a Certificate to the Store
            }
        }

        
        Write-Verbose "Publish CRL on SubCA" -Verbose
        certutil -crl
        
    }#END INVOKE-COMMAND

}