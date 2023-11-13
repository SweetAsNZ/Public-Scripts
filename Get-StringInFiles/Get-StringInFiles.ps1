<#
.Synopsis
   WIP Search for Text in by default .PS1 files which defaults to the scripting path
.DESCRIPTION
   Long description
.EXAMPLE
   Get-StringInFiles -String "enumeration"
.EXAMPLE
   Get-StringInFiles -basePath "C:\SCRIPTS\" -String "ERROR"
.EXAMPLE
   Get-StringInFiles -basePath "C:\SCRIPTS\" -String "ERROR" -ReplaceWith 'C:\SCRIPTS\' 
#>
function Get-StringInFiles
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$basePath = 'C:\SCRIPTS'
        ,
        [Parameter(Mandatory=$true)]
        [string]$String
        ,
        [Parameter(Mandatory=$false)]
        [string]$ReplaceWith
    )
    
    # Escape the backslashes in the input strings
    $String = $String -replace '\\', '\\\\'
    $ReplaceWith = $ReplaceWith -replace '\\', '\\\\'
    
    # Speed up the search with PS7 or greater
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Get-ChildItem -Path $basePath -Recurse -File | ForEach-Object -Parallel {
            $matches = Select-String -Path $_.FullName -Pattern $using:String -Context 1,1
            if ($matches) {
                foreach ($match in $matches) {
                    Write-Host -f Green "Found '$using:String' in file $($_.FullName) at line $($match.LineNumber):"
                    Write-Output "Line before: $($match.Context.PreContext)"
                    Write-Output "Match line: $($match.Line)"
                    Write-Output "Line after: $($match.Context.PostContext)"
                    
                    # Replace the string if $ReplaceWith is not null
                    if ($null -ne $using:ReplaceWith) {
                        (Get-Content $_.FullName) | ForEach-Object { $_ -replace $using:String, $using:ReplaceWith } | Set-Content $_.FullName
                    }
                }
            }
        }
    } else {
        
        # For <PS7 use standard search as no -Parallels option is available
        Get-ChildItem -Path $basePath -Recurse -File | ForEach-Object {
            $matches = Select-String -Path $_.FullName -Pattern $String -Context 1,1
            if ($matches) {
                foreach ($match in $matches) {
                    Write-Host -f Green "Found '$String' in file $($_.FullName) at line $($match.LineNumber):"
                    Write-Output "Line before: $($match.Context.PreContext)"
                    Write-Output "Match line: $($match.Line)"
                    Write-Output "Line after: $($match.Context.PostContext)"
                    
                    # Replace the string if $ReplaceWith is not null
                    if ($null -ne $ReplaceWith) {
                        (Get-Content $_.FullName) | ForEach-Object { $_ -replace $String, $ReplaceWith } | Set-Content $_.FullName
                    }
                }
            }
        }
    }
}#END FUNCTION
