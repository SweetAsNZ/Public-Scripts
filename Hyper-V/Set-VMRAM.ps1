function Set-VMRAM{
    
    # WIP - WORK IN PROGRESS

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [int]$StartupRAM,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [int]$MinimumRAM,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [boolean]$ShutdownFirst
        
    )

    $Secs = 10
    Write-Host "RAM is in MB... waiting for $($Secs) secs" -Foregroundcolor Yellow
    Start-Sleep -Seconds $Secs
    $VMModule = 'VMware.PowerCLI'

    $ModuleThere = Get-Module -ListAvailable -Name 
    if(!($ModuleThere -like "*$VMwareModule*")){
        
        Write-Warning "Installing VMware Module: $($VMModule)"
        Start-Sleep $Secs -Seconds

        Install-Module -Name "*$VMwareModule*" -Scope CurrentUser
    }
    if($ShutdownFirst -eq $true){
        Stop-VM -TurnOff $VMName 
    }
    
    $sRAM   = $StartupRAM+"MB"
    $MinRAM = $MinimumRAM+"MB"

    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes $sRAM -MinimumByte $MinRAM
}
        