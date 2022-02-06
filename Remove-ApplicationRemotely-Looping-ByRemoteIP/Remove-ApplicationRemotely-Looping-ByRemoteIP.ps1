function Remove-ApplicationRemotely-Looping-ByRemoteIP{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$AppID,
        [Parameter(Mandatory=$true)]
        [string]$ServerIP
    )
    ######################################
    ########   TREND SERVER   ############

    #$AppID = ''
    $Collection = (Get-NetTCPConnection -State Established | Where-Object {$_.LocalPort -eq 80}).RemoteAddress

    foreach ($Item in $Collection)
    {
        Invoke-Command -ComputerName $Item -ArgumentList $AppID -ScriptBlock {
        
            param(
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                $AppID
            )
        
            MSIEXEC.exe /x $AppID /qn 
        }
    }

    <#
    ##############################################
    ########   RUN FROM ALL CLIENTS   ############
    
    $ServerIP = '10.1x.1x.1x'
    $TESTPC   = Get-NetTCPConnection -State Established | Where-Object {($_.LocalPort -eq 5985) -and ($_.RemoteAddress -eq $ServerIP)}
    $TESTPC 
    #>
}