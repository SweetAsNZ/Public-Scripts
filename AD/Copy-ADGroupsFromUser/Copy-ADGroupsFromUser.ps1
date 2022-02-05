Function Copy-ADGroupsFromUser{
    # Copies Groups From One User To Another Or To Others. Requirement was to prompt so parameters were not used.
    # It does not remove existing groups from the Destination User $CopyTo

    $CopyFrom = Read-Host "Source User?"
    $CopyTo   = Read-Host "Destination User?"

    Get-ADUser -Identity $CopyFrom -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $CopyTo

   
} 


