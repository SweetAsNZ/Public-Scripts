function ClearMyVariables
{
    Get-ChildItem -Recurse C:\SCRIPTS -Include *.ps1 | 
    ForEach-Object {
        $content = Get-Content $_.FullName
        $variables = $content | Select-String -Pattern '\$\w+' -AllMatches | 
        ForEach-Object { $_.Matches } | 
        ForEach-Object { $_.Value }
        $variables | Sort | Get-Unique | ForEach-Object {
            try {
                
                Remove-Variable -Name $_.Substring(1) -ErrorAction Stop #-WhatIf
            } catch {
                #Write-Output "Failed to remove variable $_"
            }
        }
    }
    
}