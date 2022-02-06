function Get-RDPCert{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$Server,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$CertType 
    )

    Enter-PSSession -ComputerName $Server

    $WMICert = (Get-WmiObject -class “Win32_TSGeneralSetting” -Namespace root\cimv2\terminalservices).SSLCertificateSHA1Hash #-Filter “TerminalName=’RDP-tcp'”

    $FindCert = (Get-ChildItem Cert:\LocalMachine).Name
    
    if(!($CertType)){
        $CertType = '_RemoteDesktopComputerSHA256'
    }

    foreach ($Path in $FindCert){
        $WMI = Get-ChildItem Cert:\LocalMachine\$Path | Where-Object {($_.Thumbprint -eq $WMICert)} 
        $RDP = Get-ChildItem Cert:\LocalMachine\$Path | Where-Object {($_.EnhancedKeyUsage -eq $CertType)} 

        If($WMI -eq $RDP.Thumbprint){
            Write-Host "TS Cert is RDP Cert Type. RDPThumb = $($RDP), WMIThumb: $($WMICert)" -ForegroundColor Green
        }
        Elseif($WMI -ne $RDP.Thumbprint){
            Write-Host "TS Cert is NOT RDP Cert Type.  RDPThumb = $($RDP), WMIThumb: $($WMI)" -ForegroundColor Red
        }

    } 

    Exit-PSSession

}