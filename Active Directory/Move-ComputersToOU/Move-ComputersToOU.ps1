function Move-ComputersToOU{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="Target OU DN")] 
        [string]$TargetOU,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="OU Name")] 
        [string]$OUName,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$false,HelpMessage="Log File")] 
        [string]$Log
    )

    if( !(Test-Path -Path $Log) ){
        $Log = "$($env:Windir)\Temp\Machine_OUMove.log"
        New-Item -Path $Log -ItemType Directory
    }
    
    
    $TargetOU      = (Get-ADObject -Filter {Name -eq $OUName}).DistinguishedName
    $ComputerNames = @('Laptop1','Laptop2','Laptop3')

    foreach ($Item in $ComputerNames)
    {
        Get-ADObject -Filter {Name -eq $Item} | Move-ADObject -TargetPath $TargetOU 
        Add-Content -Value (Get-Date) -Path $Log
        Add-Content -Value ($env:UserName +"Did It") -Path $Log
        Add-Content -Value "$($Item) Moved to $($TargetOU)" -Path $Log
    }

}
