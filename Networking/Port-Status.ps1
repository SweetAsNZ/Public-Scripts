function Get-PortStatus {
<#
.SYNOPSIS
Gets the status of a port

If you recieve this: Get-NetTCPConnection : No MSFT_NetTCPConnection objects found with property 'LocalPort' equal to* it is  a 'No'

.DESCRIPTION

'# WIP' Means it is still a Work In Progress

###########################################
##  Author:      Tim West (BSc.)         ##
##  Company:     Sweet As Chocolate Ltd  ##
###########################################


.PARAMETER Name
N/A
.PARAMETER Extension
N/A
.INPUTS
N/A
.OUTPUTS
Screen
.EXAMPLE
Get-PortStatus -Port 80
.LINK

#>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        #[Alias("Port")] 
        [int]$Port 
    )
    
    Get-NetTCPConnection -LocalPort $Port

}





    