function New-FileCopyBasedOnStringInFile{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$Source,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$Dest,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$FileType,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$Str
    )


# Script to copy the most recent file containing a certain string from one folder to another folder on a Windows machine.

Copy-Item (Get-ChildItem -Path $Source -File -Name *.$FileType | Get-Content | Where-Object {$_ -like "*$Str*"} | Select-Object -First 1).PSPath -Destination $Dest

}