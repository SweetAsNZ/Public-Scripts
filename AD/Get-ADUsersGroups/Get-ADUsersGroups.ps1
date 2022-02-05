function Get-ADUsersGroups{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Account
    )
    
    # Get a User's Groups By Name
    # $Account = "JohnS"

    
    $Account = Read-Host "Username?"

    # Get a User's Groups By SAM Account Name
    ( (Get-ADuser -Identity $Account -Properties memberof).memberof | Get-ADGroup | Select-Object Name | Sort-Object name).Name
}