function New-FileCopyBasedOnStringInFile{
<#
.SYNOPSIS
Copies Files The Contents Of Which Are a String $Str from $Source to $Dest

.DESCRIPTION
Script to copy the most recent file containing a certain string from one folder to another folder on a Windows machine.

'# WIP' Means it is still a Work In Progress

###########################################
##  Author:      Tim West                ##
##  Company:     Sweet As Chocolate Ltd  ##
###########################################


.PARAMETER Name
[string]$Source
[string]$Dest
[string]$FileType
[string]$Str
.PARAMETER Extension
N/A
.INPUTS
N/A
.OUTPUTS
Log File
.EXAMPLE
New-FileCopyBasedOnStringInFile -Source C:\Temp -Dest C:\Temp\Folder2 -Filetype TXT -Str cat
.LINK

#>
    


    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="Source Path")] 
        [ValidateNotNullOrEmpty()] 
        [string]$Source,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="Destination Path")] 
        [ValidateNotNullOrEmpty()] 
        [string]$Dest,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$FileType,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="String to Search For In The Files")] 
        [ValidateNotNullOrEmpty()] 
        [string]$Str
    )



    Copy-Item ( Get-ChildItem -Path $Source -File -Name ("*."+$FileType) | Get-Content | Where-Object {$_ -like "*$Str*"} ).PSPath -Destination $Dest -Verbose

}

