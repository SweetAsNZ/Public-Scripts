function Get-ADUsersGroupsByUserTitle{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Title
    )
    
    # Get a User's Groups By Title.  You can use the parameter above or Read-Host 
    # $Title = "Fines Administrator"

    # If $Title is null use Read-Host
    if( !($null -eq $Title) ){
        
        $Title = Read-Host "Title of User?" ; $Title
    }
    
    
    ( (Get-ADUser -Filter {Title -eq $Title} -Properties memberof,title,whenCreated | Sort-Object whenCreated).memberof | Get-ADGroup | Select-Object Name ).Name

    $Title = $null
}