function Remove-EmptyFolders{
    [CmdletBinding()]
    Param (
        [Parameter(Position=0, Mandatory=$True,HelpMessage="Enter Path to Search",NotNullOrEmpty)]
        [String]$Path1
   )

#$REF: https://lazyadmin.nl/it/remove-empty-directories-with-powershell/

#$Path1 = "$($ENV:USERPROFILE)\Documents"

##########################################
#####   FAST REMOVE WITH ROBOCOPY   ######
# Make sure both paths are exactly the same

    Robocopy $Path1 $Path1 /S /Move
}
