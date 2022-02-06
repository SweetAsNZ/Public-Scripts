function Add-ADGroup-To-LocalAdmin{
    
    # Runs Across All Windows Servers. Requires AD RSATon the computer yseused to run the script if no $Domain is specified
    # Suggest $GroupName may be "Remote_Admins" or "Remote_Desktop_Users" or "Remote_SQL_Admins"
    # REF: https://techibee.com/active-directory/powershell-adding-a-domain-group-to-local-administrators-group-on-remote-computer/1280

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false)]
        $ComputerName,            
        [parameter(Mandatory = $false)]
        $GroupName,            
        [parameter(Mandatory = $false)]
        $DomainName 
    )


    if(!($DomainName)) { 
        
        Import-Module ActiveDirectory  # Not really required in later PS versions
        $DomainName = (Get-AdDomain).DNSRoot.ToString() ; $DomainName
    }            

    # If the parameter above is not specified use all Servers
    if( !($ComputerName) ){

        $Servers =  ( Get-ADComputer -Filter * -Properties Name,OperatingSystem,Enabled -ResultSetSize 1000000 |
         Where-Object {($_.OperatingSystem -like "Windows Server*") -and ($_.Enabled -eq $true)} | Sort-Object Name ).Name
    }
    
    if($ComputerName){
        $Servers = $ComputerName
    }

    foreach ($ComputerName in $Servers)
    {
        $GroupName = ($ComputerName + "_"+$GroupName) ; $GroupName 

        try {            

            $AdminGroup = [ADSI]("WinNT://$ComputerName/Administrators,Group")
            $AdminGroup.Add("WinNT://$DomainName/$GroupName,Group")
            
            Write-Host "Successfully Added $($GroupName) to Local Administrators Group of $($ComputerName)" -ForegroundColor Green        

        }
        catch {
            
            Write-Error -Message $_.Exception.Message

        }#END TRY CATCH

    }#END FOREACH
} 