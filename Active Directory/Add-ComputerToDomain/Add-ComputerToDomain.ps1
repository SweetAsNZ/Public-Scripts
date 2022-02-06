function Add-ComputerToDomain{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$false)]
        [string[]]$Domain
    )


    # PartOfDomain (boolean Property)
    $DomainJoined  = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
 
    # Workgroup (string Property)
    $Workgroup = (Get-WmiObject -Class Win32_ComputerSystem).Workgroup

    if( !($ComputerName)){
        
        # Assume if the machine the script is being run in is ina  Workgroup you want to join it to the domain
        if($Workgroup -ieq "WORKGROUP"){
        
            $ComputerName = $ENV:COMPUTERNAME
        }
        if($DomainJoined){
            
            $ComputerName = Read-Host "ComputerName to Add to Domain?"
        }
    }

    if( !($Domain)){
        
        # If the $Domain parameter is not specified use the below DNSRoot
        [string]$Domain = Get-ADDomain.dnsroot
        Write-Host "`r`n Domain is $($Domain)"

    }

    Add-Computer -ComputerName $ComputerName -DomainName $Domain -Credential (Get-Credential) -Restart –Force

}