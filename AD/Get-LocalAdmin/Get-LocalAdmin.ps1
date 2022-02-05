function Get-LocalAdmin{

    # REF https://www.edrockwell.com/blog/powershell-get-local-administrators-active-directory-nested-groups-sox/

    #  Requires WMI

    <#
    Get domain and server
    Import PowerShell Modules
    Get Date and Time
    Get the working directory
    Convert the domain and computername to upper and lower for pattern matches
    Start the transcript in the current directory and use some variables for naming the transcript
    Get the server’s local administrators object using Get-WmiObject and a where cause for the group component
    Get the members of the local admins and determine if it’s a user or group.
    If user, put it in the transcript and tag the user as uer
    If Group, put the group in a variable to loop through later
    In the transcript, I’m doing a Write-Host to tag each group. If the group has a sub group, (nested group), then put that in another variable to loop through that as well
    
    
    e.g. Get-LocalAdmin -ComputerName Server1 -Domain Domain1
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [string]$Domain,
        [Parameter(Mandatory=$True)]
        [string]$ComputerName
    )

    # Importing Modules
    if (! @(Get-Module -Name ActiveDirectory).count) 
    {
	    Import-Module ActiveDirectory
    }

    if (! @(Get-Module -Name Microsoft.Powershell.Host).count) 
    {
	    Import-Module Microsoft.Powershell.Host
    }

    if (! @(Get-Module -Name Microsoft.WSMan.Management).count) 
    {
	    Import-Module Microsoft.WSMan.Management
    }

    if (!($Domain)){
        $Domain      = (Get-ADDomain).Name
    }

    # VARIABLES
    $Title           = 'Get-LocalAdmin'
    $BaseDir         = 'C:\SCRIPTS\AD\'
    $WorkingDir      = Join-Path -Path $BaseDir -ChildPath "$Title\"

    $TimeStamp       = Get-Date -Format yyyyMMddHHmmss
    
    $DomainL         = $Domain.ToLower()
    $DomainU         = $Domain.ToUpper()
    $ParentDomain    = (Get-ADDomain).ParentDomain
    #[string]$StrComp = $ComputerName
    $ComputerNU      = $ComputerName.ToUpper()

    if( !(Test-Path $WorkingDir) ){
        New-Item $WorkingDir -ItemType Directory
    }

    Write-Host "Be aware that this script is logged via STart-Transcript depending on your security posture this may be undesireable" -ForegroundColor Yellow

    Set-Location $WorkingDir

    
    Start-Transcript -Path "$($WorkingDir)\LocalAdmins_$($DomainU).$($ComputerNU).$($TimeStamp).txt" -force


    # Getting the Local Admins Group
    $Admins = Get-WmiObject win32_groupuser –computer "$ComputerName.$Domain.$ParentDomain"
    $Admins = $Admins | Where-Object {$_.groupcomponent –like '*"Administrators"'} 
    [array]$DomainGroups = @()
    [array]$IsGroup = @()

    Write-Host "----------------------------------------------------------------"
    Write-Host $ComputerName "Local Administrators"
    Write-Host "----------------------------------------------------------------"

    # Getting Members of Local Admins
    $Admins | ForEach-Object {  
    
        $_.partcomponent –match "Win32_(.+).+Domain\=(.+)\,Name\=(.+)$" > $nul  
        $Matches[2].trim('"') + "\" + $Matches[3].trim('"') + " Type: " + $Matches[1]
    
        # Finding if Local Administrator member is a Domain Group and adding it to $DomainGroups
        $String = 'Win32_Group.Domain="'+$DomainU+'"'
        if ($Matches[0].Contains($String)){
            $DomainGroups += ($matches[3].trim('"'))
            }
        }

    # Looping through all the Domain Groups in the Local Admins and getting their members
    foreach ($DomainGroup in $DomainGroups){
    
        Write-Host "----------------------------------------------------------------"
        Write-Host "$DomainGroup"
        Write-Host "----------------------------------------------------------------"
    
        $Members = Get-ADGroupMember $DomainGroup -server "$DomainL.$parentDomain"
        # If a group member is another group write it to $IsGroup so we can get them later
        foreach ($Member in $Members){
            If ($Member.objectclass -eq "user"){
                Write-host ($Member.name)" Type:"($Member.objectClass)
                }
            elseif ($Member.objectclass -eq "group" -And $IsGroup -notcontains $Member){
                Write-Host ($member.name)" Type:"($member.objectClass)
                $IsGroup += $Member
                }
            elseif($Member.objectclass -eq "group" -And $IsGroup -contains $Member){
                }
            }
        }
    # As stated above, getting the members of nested groups
    foreach ($Item in $IsGroup){
    
        Write-Host "----------------------------------------------------------------"
        Write-Host $Item.name
        Write-Host "----------------------------------------------------------------"
    
        $DN = $Item.distinguishedName
        $ObjectDomain = ((($DN -replace "(.*?)DC=(.*)",'$2') -replace "DC=","") -replace ",",".")
    
        $Members = Get-ADGroupMember $Item -server $ObjectDomain
        foreach ($Member in $Members){
            write-host $Member.name" Type:"$Member.objectClass
            }
        }

    Stop-Transcript
}
