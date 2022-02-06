# REF: https://docs.microsoft.com/en-us/troubleshoot/windows-server/remote/remote-desktop-listener-certificate-configurations
# REF: https://rakhesh.com/powershell/using-powershell-to-insert-a-space-between-characters-or-using-powershell-to-show-certificate-fingerprints-in-a-friendly-format/

###########################
# WIP - Work In Progress
###########################

# Create A Cert for RDP

$DNSName = @("$env:COMPUTERNAME","$env:COMPUTERNAME.$env:USERDNSDOMAIN")
$Cert = Get-Certificate -Template '_RemoteDesktopComputerSHA256' -DnsName $DNSName -SubjectName "CN=$env:COMPUTERNAME"  -CertStoreLocation Cert:\LocalMachine\My -Url LDAP: 

function Certificate_Template {

    $Template = "_RemoteDesktopComputerSHA256"
    $CertStore = 'Cert:\LocalMachine\My'

    Get-ChildItem $CertStore | 
    ForEach-Object{
        $_ | Select-Object Thumbprint,FriendlyName,@{N="Template";E={($_.Extensions |
             Where-Object {$_.oid.Friendlyname -match "Certificate Template Information"}).Format(0) `
        -replace "(.+)?=(.+)\((.+)?", '$2'}},@{N="Subject";E={$_.SubjectName.name}}
    }
}
$Template = "_RemoteDesktopComputerSHA256"
$RDPCert = Certificate_Template | Where-Object {($_.Template -eq $Template)}

# Set Friendly Name 
$FriendlyName = "$($ENV:COMPUTERNAME) Remote Desktop Certificate"
Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object {$_.Thumbprint -eq ($RDPCert).Thumbprint} | ForEach-Object { $_.FriendlyName = "$FriendlyName" }

# Create Registry Value
$PreValue = ( ($RDPCert).Thumbprint -split "([a-z0-9]{2})"  | Where-Object{ $_.length -ne 0 }) -join ","  # Separate every 2 characters of the thumbprint with a comma
$Value = '"SSLCertificateSHA1Hash"=hex:'+$PreValue

#Create a reg file for import.
$String  = 'Windows Registry Editor Version 5.00' + "`r`n" + "`r`n"  # `r=Carriage Return and `n=Line Feed/New Line = CRLF
$String += '[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]' + "`r`n"
$String += $Value + "`r`n"
$String | Out-File -FilePath "$($env:USERPROFILE)\Desktop\RDPCert.reg" -Encoding ascii -Force

# Import the Reg File
Reg Import "$($env:USERPROFILE)\Desktop\RDPCert.reg"


Restart-Service TermService -force