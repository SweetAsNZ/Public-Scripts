function Get-ADUsersGroupsByUserTitle{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Title
    )
    
    # Get a User's Groups By Name
    # $Title = "Fines Administrator"

    $Title = Read-Host "Title of User?"
    
    ( (Get-ADUser -Filter {Title -eq $Title} -Properties memberof,title,whenCreated | Sort-Object whenCreated).memberof | Get-ADGroup | Select-Object Name ).Name
}