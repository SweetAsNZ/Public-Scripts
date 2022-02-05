function Get-ADUsersGroups{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Account
    )
    
    # Get a User's Groups By User Name
    # $Account = "JohnS"

     # If $Account is null use Read-Host
     if( !($null -eq $Account ) ){
        
        $Account = Read-Host "Username?" ; $Account
    }

    # Get a User's Groups By SAM Account Name
    ( (Get-ADuser -Identity $Account -Properties memberof).memberof | Get-ADGroup | Select-Object Name | Sort-Object name).Name
}