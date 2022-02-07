function Create-VirtualMachine{

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$VMPath,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$ISO,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [int]$RAM,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [int]$DiskSpace
    )
        #$VMName = "Kali"
        #$ISO    = "C:\TEMP\SW_DVD9_Win_Pro_10_1703.1_64BIT_English_MLF_X21-47998.ISO"
        #$ISO    = "C:\TEMP\en_windows_server_2019_updated_jan_2020_x64_dvd_9069e1c0.iso"
        #$ISO    = "C:\TEMP\kali-linux-2021-1-installer-amd64-iso\kali-linux-2021.1-installer-amd64.iso"

        $InstWC = Get-WindowsCapability -Name 'Hyper-V'
        $InstWF = Get-WindowsFeature -Name 'Hyper-V'
        
        if($InstWC){
            
            $InstallHV = Read-Host "Install Hyper-V Host Y/N?"
            if($InstallHV -ieq 'Y'){
                Install-WindowsFeature -Name Hyper-V -IncludeManagementTools # -Restart
            }
        }
        if($InstWF){
            
            $InstallHV = Read-Host "Install Hyper-V Host Y/N?"
            if($InstallHV -ieq 'Y'){
            
                Install-WindowsFeature -Name Hyper-V -IncludeManagementTools # -Restart
            }
        }
        
        $RAMSize = $RAM + "MB"
        New-VM -Name $VMName -MemoryStartupBytes $RAMSize -Path "$VMPath\$VMName"
        New-VHD -Path "$VMPath\$VMName.vhdx" -SizeBytes $DiskSpace -Dynamic
        Add-VMHardDiskDrive -VMName $VMName -Path "$VMPath\$VMName.vhdx" 
        Set-VMDvdDrive -VMName $VMName -ControllerNumber 1 -Path $ISO

        Add-VMNetworkAdapter -VMName $VMName -SwitchName "Default Switch" –Name "Network Adapter"

        Start-VM –Name $VMName
        Get-VM $VMName

        #  Calculate RAM Usage
        $Bytes = ( ( (Get-VM $VMName| Get-VMMemory) | Measure-Object -Sum Startup ).Sum )
        $Bytes
        $GB = $($Bytes)/1000000000 
        $GB = [math]::Round($GB,1)
        Write-Host "$($GB)"
        Write-Host "VM $($VMName): RAM $($GB) GB Total `r`n"

        # Dump List of VM's
        $Date = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames
        (Get-VM).Name | Export-CSV "$($ENV:USERPROFILE)\Documents\VMs_$($Date).csv" -NoTypeInformation

}