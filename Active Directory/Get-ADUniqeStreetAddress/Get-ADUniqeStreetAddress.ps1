function Get-ADUniqeStreetAddress{}

    # Unique Street Addresses
    $Addresses = (Get-ADUser -Filter * -Properties Enabled,Name,StreetAddress | Where-Object {($_.Enabled -eq $true) -and ($_.StreetAddress -ne $null)}).StreetAddress 
    $Addresses | Sort-Object | Get-Unique

    # Get User With Address
    $Address = ""
    Get-ADUser -Filter * -Properties Name,StreetAddress| Where-Object {($_.StreetAddress -eq $Address)}
}