function Get-ADStaleComputers{

    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$OU,
        [Parameter(Mandatory=$False)]
        [string]$Days,
        [Parameter(Mandatory=$true)]
        [ValidateSet("ComputerAccountPasswordChanged","LastLoginTimestamp")]
        [string]$Query
    )


    # Get PC's & Servers That Have Not Been On The Network For A While

    # $OU = "CN=XXX,CN=XX"  # This is the top level to search from if you like to use this

    if (!($OU)){
        $OU           = Get-ADDOmain.DistinguishedName  # This will get all from the top level
    }

    if ( !($Days) ){
        $daysInactive = [DateTime]::Today.AddDays(-90)
    }
    if ($days) {
        $daysInactive = [DateTime]::Today.AddDays(-$Days)
    }

    if($Query -eq "ComputerAccountPasswordChanged"){
        # By Last Time The Computer Account Password Changed
        $PWDls = Get-ADComputer -Filter  'PasswordLastSet -le $daysInactive' -SearchBase $OU -Properties PasswordLastSet,Enabled | Where-Object {($_.Enabled -eq $true)} |
        Select-Object Name,Enabled,PasswordLastSet,DistinguishedName | Sort-Object PasswordLastSet
        $PWDls #| Select -First 20
    }

    if($Query -eq "LastLoginTimestamp"){
        # By Last Login Time.  I think the last login tiemstamp doesn't replicate
        $LLts = Get-ADComputer -Filter {lastlogontimestamp -lt $daysInactive} -Properties Name,OperatingSystem,lastlogontimestamp,Enabled | 
        Where-Object {($_.Enabled -eq $true)} |
        Select-Object Name,OperatingSystem,Enabled,@{N='lastlogontimestamp'; E={[DateTime]::FromFileTime($_.lastlogontimestamp)}} | 
        Sort-Object lastlogontimestamp

        $LLts #| Select -First 20
    }
}