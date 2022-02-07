Function Remove-EmptyFolder{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,HelpMessage="Enter Path to Search?",NotNullOrEmpty)]
        [String]$Path1,
        [Parameter(Mandatory=$True,HelpMessage="Find Hidden Files Too?",NotNullOrEmpty)]
        [String]$RemoveHiddenFiles
        [Parameter(Mandatory=$True,HelpMessage="UseWhatif?",NotNullOrEmpty)]
        [String]$Whatif
        
   )


    ##########################################
    #######   REMOVE WITH POWERSHELL   #######
    # Remove empty directories locally

    # Set to true to test the script
    $whatIf = $true

    # Remove hidden files like thumbs.db
    $removeHiddenFiles = $true

    # Get hidden files or not. Depending on removeHiddenFiles setting
    $getHiddenFiles = !$removeHiddenFiles

    # Go through each subfolder, 
    Foreach ($subFolder in Get-ChildItem -Force -Literal $path -Directory) 
    {
        # Call the function recursively
        Delete-EmptyFolder -path $subFolder.FullName
    }

    # Get all child items
    $subItems = Get-ChildItem -Force:$getHiddelFiles -LiteralPath $path

    # If there are no items, then we can delete the folder
    # Exluce folder: If (($subItems -eq $null) -and (-Not($path.contains("DfsrPrivate")))) 
    If ($null -eq $subItems) 
    {
        Write-Host "Removing empty folder '${path}'"
        Remove-Item -Force -Recurse:$removeHiddenFiles -LiteralPath $Path -WhatIf:$whatIf
    }
}
