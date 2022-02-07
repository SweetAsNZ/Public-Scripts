function Get-PortStatus {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("Port")] 
        [string]$Port 
    )
    
    Get-NetTCPConnection -LocalPort $Port
}
Get-PortStatus -Port 443