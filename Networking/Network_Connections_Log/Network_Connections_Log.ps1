function Get-NetworkConnections{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$OutputPath,
        [Parameter(Mandatory=$true)]
        [string]$lPort
    )
    
# Log Network Connections of the local computer

if(!($OutputPath)){
    $OutputPath = "C:\SCRIPTS\Network_Connections_Log\Network_Connections_$($env:COMPUTERNAME).log"
}

# Setup loop
$TimeStart = Get-Date
$TimeEnd = $timeStart.AddHours(24)

Do { 
$TimeNow = Get-Date

if ($TimeNow -ge $TimeEnd) {
    Write-host "It's time to finish."
 } 
else {
    Get-NetTCPConnection -State Established | Where-Object {$_.LocalPort -eq $lPort} | Select-Object RemoteAddress `
    | Export-CSV $OutputPath -NoTypeInformation -Append
 }
 
Start-Sleep -Seconds 1
}
Until ($TimeNow -ge $TimeEnd)

