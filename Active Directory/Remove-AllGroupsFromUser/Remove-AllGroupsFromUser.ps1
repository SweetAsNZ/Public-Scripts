
function Remove-AllGroupsFromUser{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Users
    )

    if (!($Users )){
        
        #$Users = 'JohnSmith1' # @('JohnSmith1','JohnSmith2')
        if (!($Users )){
            
            $Users = Read-Host "Username(s)? e.g., JohnSmith1 or e.g. @('JohnSmith1','JohnSmith2')"
        }
    }#END IF BIG

    ForEach($SAMAccountName in $Users) {
        $ADGroups = Get-ADPrincipalGroupMembership -Identity $SAMAccountName | Where-Object {$_.Name -ne "Domain Users"}

        # Removing group membership from a user account
        Remove-ADPrincipalGroupMembership -Identity  $SAMAccountName -MemberOf $ADGroups -Confirm:$false -verbose
    }
}