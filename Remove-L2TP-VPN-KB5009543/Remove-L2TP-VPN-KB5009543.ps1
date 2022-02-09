# Removes L2TP VPN Dodgy Update
# WUSA Didn't Work. Unknown RCA - Tim West 9/2/22 1156hrs


$KB    = 'KB5009543'
$KB2   = "19041.1466.1.6"  # Same KB as above but ID for DISM (I guess -TW)

$Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
$LogF  = "$($env:windir)\Temp\$($KB)_Removal_$($Date).log"

$Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
Add-Content -Path $LogF -Value "Starting - $($Date)"


try{
    $Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
    Add-Content -Path $LogF -Value "Trying - $($Date)"

    Start-Process -FilePath "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" -Verb RunAs -Wait -ArgumentList "WUSA.exe /uninstall /quiet /kb:5009543 /norestart" 
    
    $Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
    Add-Content -Path $LogF -Value "Post Start Process - $($Date)"
    
    if(!(Get-HotFix -Id $KB)){
        
        Write-Output "Dodgy Hotfix Is Gone YAY!"
        Add-Content -Path $LogF -Value "Hotfix $($KB) Is Fully Gone. YAY!"
    }
    if(Get-HotFix -Id $KB){
        Write-Output "Dodgy Hotfix Is Not Gone. Dammit!"
        Add-Content -Path $LogF -Value "Hotfix $($KB) Still Exists. Bugger!"
    }

    
    if(Get-HotFix -Id $KB){
        
        $Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
        Add-Content -Path $LogF -Value "Error Hotfix Still Found!! Trying to DISM REMOVE - $($Date)"

        try{
            
            Add-Content -Path $LogF -Value "DISM REMOVE START - $($Date)"
            $CmdOutput = "Update " + $KB2 + " not found."

            $SearchUpdates = dism /online /get-packages | findstr "Package_for" | findstr "$KB2"
            Add-Content -Path $LogF -Value "$($SearchUpdates)"
            
            if ($SearchUpdates){
                $update    = $SearchUpdates.split(":")[1].replace(" ", "")
                Add-Content -Path $LogF -Value "$($update)"
                
                $CmdOutput = dism /Online /Remove-Package /PackageName:$update /quiet /norestart
                Add-Content -Path $LogF -Value "$($CmdOutput)"
            }
            
            Add-Content -Path $LogF -Value "DISM Remove Tried Successfully"

            if(!(Get-HotFix -Id $KB)){
        
                Write-Output "Dodgy Hotfix Is Gone YAY!"
                Add-Content -Path $LogF -Value "Hotfix $($KB) Is By DISM Fully Gone. YAY!"
            }
            if(Get-HotFix -Id $KB){
                Write-Output "Dodgy Hotfix Is Not Gone. Dammit!"
                Add-Content -Path $LogF -Value "Hotfix $($KB) Post DISM Still Exists. Bugger!"
            }
            
        }
        catch{
        
            $Err = $($PSItem.ToString())
            $Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames

            Add-Content -Path $LogF -Value "Catch1 - $($Date)"
            Add-Content -Path $LogF -Value "$($Err)"
            Add-Content -Path $LogF -Value "FAILED Removal of $($KB) via DISM. Removal Error Code B66556-TW"
        }
    }
}
catch{
    
    $Err = $($PSItem.ToString())
    
    $Date  = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
    Add-Content -Path $LogF -Value "Catch2 - $($Date)"
    Add-Content -Path $LogF -Value "$($Err)"

    Add-Content -Path $LogF -Value "FAILED Removal of $($KB) via WUSA. Removal Error Code B55445-TW"


}

Add-Content -Path $LogF -Value "`r`r Hotfix Removal Script FINISHED `r`n"
