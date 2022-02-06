function Compare-ADUsersGroups{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$newUser
    )

    # Compare the AD Groups of 2 Users based on the title of the New User.

    $NewUserTitle = Get-ADUser -Filter {SAMAccountName -eq $newUser} -Properties SAMAccountName,DisplayName,Title
    $ExistingUser = (Get-ADUser -Filter * -Properties DisplayName,Title |
    Where-Object {($_.Title -eq ($NewUserTitle).Title) -and ($_.enabled -eq $true)} | Select-Object -First 1)

    "Existing User is: " + $ExistingUser.DisplayName + ": " + $ExistingUser.Title


    Compare-Object -ReferenceObject (Get-AdPrincipalGroupMembership $newUser |
    Select-Object Name | Sort-Object -Property Name) -DifferenceObject (Get-AdPrincipalGroupMembership $existingUser |
    Select-Object Name | sort-object -Property Name) -Property Name -PassThru

}