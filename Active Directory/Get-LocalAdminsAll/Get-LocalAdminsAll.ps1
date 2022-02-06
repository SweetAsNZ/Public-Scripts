function Get-LocalAdminsAll{
    
    $Servers =  (Get-ADComputer -Filter * -Properties Name,OperatingSystem,Enabled -ResultSetSize 1000000 |
     Where-Object {($_.OperatingSystem -like "Windows Server*") -and ($_.Enabled -eq $true)} | Sort-Object Name).Name

    # GLOBAL VARIABLES
    $BaseDir         = 'C:\SCRIPTS\AD\'
    $Title           = 'Get-LocalAdminsAll'
    $FolderDT        = ((Get-Date -f "yyyyMMdd_HHmm").ToString())
    $WorkingDir      = Join-Path -Path $BaseDir -ChildPath "$Title\$FolderDT\"


    foreach ($ComputerName in $Servers)
    {

        # VARIABLES
        $TimeStamp       = Get-Date -Format yyyyMMddHHmmss
        #$ComputerNL      = $ComputerName.ToLower()
    
        $Domain          = (Get-ADDomain).Name
        $DomainL         = $Domain.ToLower()
        $ComputerNU      = $ComputerName.ToUpper()
        $DomainU         = $Domain.ToUpper()
        $ParentDomain    = (Get-ADDomain).ParentDomain
        [string]$StrComp = $ComputerName

        if( !(Test-Path $WorkingDir) ){
            New-Item $WorkingDir -ItemType Directory
        }


        Set-Location $WorkingDir


        Start-Transcript -Path "$($WorkingDir)LocalAdmins_$($DomainU).$($ComputerNU).$($TimeStamp).txt" -force


        # Getting the Local Admins Group
        $Admins = Get-WmiObject win32_groupuser –computer "$ComputerName.$Domain.$ParentDomain"
        $Admins = $Admins | where {$_.groupcomponent –like '*"Administrators"'} 
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
                if($Member.objectclass -eq "user"){
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
        }#END FOREACH

        Stop-Transcript
        
    }#END FOREACH BIG
    
}#END FUNCTION