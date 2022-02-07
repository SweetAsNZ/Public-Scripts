function Get-IPOctets{
<#
.SYNOPSIS
Get IP(s) by the octet and also replace the last octet with a new number

.DESCRIPTION


'# WIP' Means it is still a Work In Progress

###########################################
##  Author:      Tim West                ##
##  Company:     Sweet As Chocolate Ltd  ##
###########################################


.PARAMETER Name
$IPs e.g. '172.21.122.222','10.11.21.31'
$LastOctet  e.g. 254 = 172.21.122.254

.PARAMETER Extension
N/A
.INPUTS
N/A
.OUTPUTS
IP with last octet replaced.
IP's by octet.
.EXAMPLE
Just Run it
.LINK

#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$IPs,
        [Parameter(Mandatory=$true)]
        [string]$LastOctet
    )
    
    
    Write-Output "`r`n Replace Last Octet With `$LastOctet `r`n"
    
    #$IPs | foreach-object {$_ -replace '\d+$',$LastOctet}
    $IPs -replace '\d+$',$LastOctet

    
    $EachOctet = foreach ($item in $IPs) {
        
        $1stOctet = ([ipaddress] $item).GetAddressBytes()[0] 
        $2ndOctet = ([ipaddress] $item).GetAddressBytes()[1] 
        $3rdOctet = ([ipaddress] $item).GetAddressBytes()[2] 
        $4thOctet = ([ipaddress] $item).GetAddressBytes()[3] 
        
        Write-Output "###########  END OF IP ADDRESS  ##################### `r`n"
    }

    $EachOctet


}