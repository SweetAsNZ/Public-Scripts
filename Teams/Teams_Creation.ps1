function New-TeamsCreate{
    <#
    .SYNOPSIS
    # Create MS Team based on CSV And Add Channels, Owners, Members and Set Visibility



    .DESCRIPTION
    CSV Fields: TeamName,Description,Visibility,Owners,Members # Owners and Members separated by semicolon
    e.g. First Row: Tim Test Team,AATim.West@hawkins.co.nz,tim.west@hawkins.co.nz;melanie.roskam@hawkins.co.nz


    '# WIP' Means it is still a Work In Progress

    ###########################################
    ##  Author:      Tim West                ##
    ##  Company:     Sweet As Chocolate Ltd  ##
    ###########################################


    .PARAMETER Name
    N/A
    .PARAMETER Extension
    N/A
    .INPUTS
    CSV File
    .OUTPUTS
    Log File
    .EXAMPLE
    Update CSV name and path Run it
    .LINK
    https://blog.jijitechnologies.com/New-teams-microsoft-teams-powershell
    #>

    [CmdletBinding()]
	param(
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="Logging Server")] 
        [ValidateNotNullOrEmpty()] 
        [string]$LogServer,
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true,HelpMessage="MS 365 Tenant Name if unsure Run Get-AzureADTenantDetail")] 
        [ValidateNotNullOrEmpty()] 
        [string]$Tenant
        
    )

    $ErrorActionPreference = "STOP"

    $Date     = (Get-Date).ToString("s").Replace(":","-")
    $TransLog = "\\$LogServer\C$\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Scripts\TRANSSCRIPTS\PS_ISE_Transcript_$($ENV:COMPUTERNAME)_$($DATE).log"

    Start-Transcript -Path $TransLog -Append -IncludeInvocationHeader
    

    ###############################################
    ####   $File    = "HCV1.csv" # EDIT THIS   ####
    ###############################################
    
    $UPN     = "$($env:USERNAME)@$($env:userdnsdomain)"
    $CSVPath = "\\$LogServer\c$\Users\$($env:USERNAME)\Documents\DROPBOX_MIGRATION\MIGRATION" 
    $Log     = "\\$LogServer\C$\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Scripts\Teams\Logs\Teams_Creation_$($Date).log"


    $CSVFile = Join-Path $CSVPath $File

    if(Test-Path -Path $CSVFile){
        Write-Output "No File $($CSVFile)"
    }
    if(Test-Path -Path $Log){
        Write-Output "No File $($Log)"
    }

    # Check all Columns Are There.
    $CF = Get-Content $CSVFile | Select-Object-First 1 ;$CF
    if($CF -notlike "*Visibility*" -and $CF -notlike "*Description*" -and $CF -notlike "*Members*" -and $CF -notlike "*Owners*" -and $CF -notlike "*TeamName*" -and $CF -notlike "*Channel*"){
        Write-Error "Column Missing"
    }
    Get-Content $CSVFile | Select-Object -First 2 -Skip 1
    PAUSE


    $AddOwners  = Read-Host "Add Owners to Teams Y/N?"
    $AddMembers = Read-Host "Add Members to Teams Y/N?"
    $CheckSPO   = Read-Host "Check SPO Sites Afterwards Y/N?"
    $ConnectNow = Read-Host "Connect to Teams & EXO Y/N?"


    if(!(Get-Module -ListAvailable -Name MicrosoftTeams)){
        Install-Module MicrosoftTeams -Scope CurrentUser
    }

    if(Get-Module -ListAvailable -Name MicrosoftTeams){
        Import-Module MicrosoftTeams 

        Write-Output "Connecting to MS Teams Online"
        Connect-MicrosoftTeams 
    }
    


    if($ConnectNow -ieq 'Y'){
        
        $DisconnectAfter = Read-Host "Disconnect Teams & EXO Afterwards Y/N?"
    
        Import-Module ExchangeOnlineManagement 
        Connect-ExchangeOnline #Connect-EXO#>
    }
    if($ConnectNow -ieq 'N'){
        Write-Debug "Not Connecting Yet Per Choice"
    }


    function New-Channel
    {   
    param ($ChannelName,$GroupId)   
        Process{
            try{
                
                $TeamChannels = $ChannelName -split ";" 
                
                if($TeamChannels){
                    
                    for($i =0; $i -le ($TeamChannels.count - 1) ; $i++){
                        New-TeamChannel -GroupId $GroupId -DisplayName $TeamChannels[$i]
                    }
                }
            }
            Catch{
                
                $Failure1 = $PSItem.ScriptStackTrace
                Write-Host "Channel Creation FAILURE - $($Failure1)" -ForegroundColor Red
                
            }
        }
    }


    function Add-Users{   
        param($Users,$GroupId,$CurrentUsername,$Role)   
        
        Process{
            try{
                
                $Teamusers = $Users -split ";" 
                
                if($Teamusers) {
                    for($j =0; $j -le ($Teamusers.count - 1) ; $j++) {
                        if($Teamusers[$j] -ne $CurrentUsername) {
                            Add-TeamUser -GroupId $GroupId -User $Teamusers[$j] -Role $Role | Out-File $Log -Append
                        }
                    }
                }
            }
            Catch{
                
                $PSItem.ScriptStackTrace | Out-File $Log -Append
                Write-Host "User Addition FAILURE" -ForegroundColor Red
                
            }
        }
    }


    function New-NewTeam 
    {   
        param ($CSVFile)   
        
        $GetTeam = (Get-Team -NumberOfThreads 20) # Max threads is 20
        Start-Sleep -Seconds 10
        
        Test-Path $CSVFile ; $CSVFile 
        $Teams   = Import-Csv $CSVFile
        Get-Content $CSVFile 
            
        foreach($Team in $Teams)
        {
                Write-Output "$($Team)"
                
                if($Team.TeamName -eq "" -or $null -eq $Team.TeamName){
                    Write-Warning "`$Team.TeamName $($Team.TeamName) is blank"
                }
                if($Team.Visibility -eq "" -or $null -eq $Team.Visibility){
                    Write-Warning "$($Team.TeamName) `$Team.Visibility $($Team.Visibility) is blank"
                }
                if($Team.Description -eq "" -or $null -eq $Team.Description){
                    Write-Warning "$($Team.TeamName) `$Team.Description $($Team.Description) is blank"
                }
                if($Team.Visibility -eq "" -or $null -eq $Team.Visibility){
                    Write-Warning "$($Team.TeamName) `$Team.Visibility ($Team.Visibility) is blank"
                }
                if($Team.Owners -eq "" -or $null -eq $Team.Owners){
                    Write-Warning "$($Team.TeamName) `$Team.Owners $($Team.Owners) is blank"
                }
                if($Team.Members -eq "" -or $null -eq $Team.Members){
                    Write-Warning "$($Team.TeamName) `$Team.Members $($Team.Members) is blank"
                }
                
                $Team 
                Write-Error "The Following Should Be null:`r`n"
                $GT = $GetTeam | Where-Object { $_.DisplayName -eq $Team.TeamName}   # Should be null

                If($null -eq $GT -or "") 
                {
                    
                    Try{
                        Write-Host "Start creating the team: $($Team.TeamName). Adding Members: $($AddMembers), Adding Owners: $($AddOwners)"
                    
                        $MailNickName = ( $Team.TeamName.Replace(' ','_') )   # Removes Spaces in the Folder name or else a Mailnickname (and path) of e.g. 'msteams_a3a622' will be auto-created
                        

                        # If the Mailnickname exists still create the team based on it as $GT has proven the team doesn't exist.
                        $MailNickExists = Get-UnifiedGroup -Identity $MailNickName -ErrorAction SilentlyContinue # Don't care if it errors
                        If( ($MailNickExists).DisplayName -eq $Team.TeamName){
                            
                            Write-Host "(`$MailNickExists).DisplayName -eq (`$Team.TeamName)"

                            $GiD =  $MailNickExists.Name # same as (Get-UnifiedGroup -Identity $MailNickName).Id
                            try{
                                Write-Host "Creating New-Team with `$GiD $($Team.TeamName) MailNickname: $($MailNickName)"
                                $Group = New-Team -Group $GiD -DisplayName $Team.TeamName -Visibility $Team.Visibility -Description $Team.Description -Verbose
                            }
                            catch{
                                Write-Warning "Error1 with New-Team $($Team.TeamName) MailNickname: $($MailNickName)"
                                $PSItem.ScriptStackTrace
                                $PSItem.ScriptStackTrace | Out-File $Log -Append

                                try{
                                    $Group = New-Team -DisplayName $Team.TeamName -Visibility $Team.Visibility -Description $Team.Description -MailNickName $MailNickName
                                }
                                catch{
                                    Write-Warning "Error2 with New-Team $($Team.TeamName) MailNickname: $($MailNickName)"
                                    $PSItem.ScriptStackTrace
                                    $PSItem.ScriptStackTrace | Out-File $Log -Append
                                }
                            }
                            
                        } # END IF

                        If( ($MailNickExists).DisplayName -ne $Team.TeamName){
                            
                            try{
                                Write-Host "Continuing creation of the team: $($Team.TeamName)"
                                $Group = New-Team -DisplayName $Team.TeamName -Visibility $Team.Visibility -Description $Team.Description -MailNickName $MailNickName 
                            }
                            catch{
                                Write-Warning "Error1 with Set-UnifiedGroup $($Team.TeamName) MailNickname: $($MailNickName)"
                                $PSItem.ScriptStackTrace
                                $PSItem.ScriptStackTrace | Out-File $Log -Append

                                $CF = Get-Content $CSVFile | Select-Object-First 1
                                if($CF -notlike "*Visibility*" -and $CF -notlike "*Description*" -and $CF -notlike "*Members*" -and $CF -notlike "*Owners*" -and $CF -notlike "*TeamName*" -and $CF -notlike "*Channel*"){
                                    Write-Error "Column Missing"
                                }
                            }
                            
                        }
                        try{
                            Write-Host "Continue #2 creation of the team: $($Team.TeamName)"
                            Set-UnifiedGroup $Team.TeamName -UnifiedGroupWelcomeMessageEnabled:$false  # Turn off notification email
                        }
                        catch{
                            Write-Warning "Error2 with Set-UnifiedGroup $($Team.TeamName) MailNickname: $($MailNickName)"
                            $PSItem.ScriptStackTrace
                        }
                    }# END TRY BIG
                    Catch{
                        Write-Warning "Error2 Creating $($Team.TeamName) MailNickname: $($MailNickName)"
                        $PSItem.ScriptStackTrace
                    }
                    
                    # Comment out to improve speed of creation if IF statements are wrong
                    If($Team.ChannelName -ne ""){
                        
                        try{
                            Write-Host "Creating channel: $($Team.ChannelName)"
                            New-Channel -ChannelName $Team.ChannelName -GroupId $group.GroupId | Out-File $Log -Append
                        
                        }
                        Catch{
                            Write-Warning "Error1 Creating $($Team.ChannelName) of $($Team.TeamName)"
                            $PSItem.ScriptStackTrace
                        }

                    }
                    
                    # Add Member(s)    
                    if($AddMembers -ieq "Y" -and $Team.Members -ne ""){
                        
                        try{
                            Add-Users -Users $Team.Members -GroupId $group.GroupId -CurrentUsername $UPN -Role Member | Out-File $Log -Append
                            Write-Host "Adding Team Members..." | Out-File $Log -Append
                        }
                        Catch{
                            Write-Warning "Error1 Adding $($Team.Members) of $($Team.TeamName)"
                            $PSItem.ScriptStackTrace
                        }

                    }
                    
                    # Add Owner(s)
                    if($AddOwners -ieq "Y" -and $Team.Owners -ne "" -and $WelcomeMsgOff -eq $true){
                    
                        try{
                            Add-Users -Users $Team.Owners -GroupId $group.GroupId -CurrentUsername $UPN -Role Owner 
                            Write-Host "Adding Team Owners... $($Team.Owners)"
                        }
                        catch{
                            Write-Warning "Error1 Adding $($Team.Members) of $($Team.TeamName)"
                            $PSItem.ScriptStackTrace
                        }
                    }
                    
                    # Add Myself only
                    if($AddMembers -ieq "N" -and $AddOwners -ieq "N"){
                        
                        try{
                            Add-Users -GroupId $group.GroupId -CurrentUsername $UPN -Role Owner
                        }
                        catch{
                            Write-Warning "Error1 Adding `$Team.Member $($UPN) on $($Team.TeamName)"
                            $PSItem.ScriptStackTrace
                        }
                    }

                    If($Team.Owners -ne "" -and $WelcomeMsgOff -eq $False){
                        
                        try{
                            Write-Host "2Setting Welcome Message Off)" -ForegroundColor Green
                            Set-UnifiedGroup $Team.TeamName -UnifiedGroupWelcomeMessageEnabled:$false  # Turn off notification email
                        }
                        catch{
                            Write-Warning "Error1 Removing WElcome Message for $($Team.TeamName) $($Group.GroupID)"
                            $PSItem.ScriptStackTrace
                        }
                        try{
                            Write-Host "Adding team owners... $($Team.Owners)"
                            Add-Users -Users $Team.Owners -GroupId $group.GroupId -CurrentUsername $UPN -Role Owner 
                        }
                        catch{
                            Write-Warning "Error1 Removing WElcome Message for $($Team.TeamName) $($Group.GroupID)"
                            $PSItem.ScriptStackTrace
                        }
                    } # END IF
                    
                }# END IF


            } # END FOREACH
        
    } # END FUNCTION

    # Execute
    New-NewTeam $CSVFile
    #>

    function Get-NewTeams{
        
        $NewTeam = (Get-Team -NumberOfThreads 20) # Max threads is 20
        
        $t = foreach($Team in $Teams){
            $NewTeam | Where-Object { $_.DisplayName -eq $Team.TeamName} | Select-ObjectDisplayName
        }
        $t
        Write-Host "" ; Write-Host "MS Teams:"
        $t.count

        If($CheckSPO -ieq "Y"){
            
            # Check SPO Site for Team
            Import-Module Microsoft.Online.SharePoint.PowerShell
            
            
            Connect-SPOService -Url "https://$($TENANT)-admin.sharepoint.com" 
        
            $w = foreach($Team in $Teams){
            
                $TargetURL = ($team).'Destination Path' -replace "/Shared Documents","" ; $TargetURL
                Get-SPOSite -Limit ALL | Where {$_.URL -eq $TargetURL}

            }# END FOREACH
            $w
            Write-Host "" ; Write-Host "SPO Sites:"
            $w.count

            # DISCONNECT IN LATER FUNCTION
        } # END IF
    }
    Check-NewTeams

    if($ConnectNow -ieq 'Y'){
        # Remove Group From Outloook GAL
        function Remove_Team_From_GAL{
        
        
            #Connect-ExchangeOnline #-UserPrincipalName "$($env:USERNAME).$($env:USERDNSDOMAIN)"
            #Import-Module ExchangeOnlineManagement
        
            $Teams = Import-Csv $CSVFile    
            foreach($Team in $Teams) {
                Get-UnifiedGroup $Team.TeamName | Set-UnifiedGroup -HiddenFromExchangeClientsEnabled:$true
            
            }
        
        } # END FUNCTION
        Remove_Team_From_GAL
    }

    function Disconnect-All{
        if($DisconnectAfter -ieq 'Y'){
            
                Write-Host "Disconnecting Teams, EXO & SPO" -ForegroundColor Green
                Disconnect-MicrosoftTeams -Confirm:$false
                Disconnect-ExchangeOnline -Confirm:$false
                Disconnect-SPOService 
        } # END IF
    }
    Disconnect-All

    Function Remove-Team{
        foreach($Team in $Teams) {
            Get-Team | Where-Object { $_.displayname -eq $Team.TeamName} | Remove-Team
        }
    } # End Function


    Write-Host ""
    Stop-Transcript -Verbose


    # Open Log File
    # Notepad $Log
    <#
    # Check
    Get-Team | Where {($_.DisplayName -like "$($ENV:Username) Test Dropbox*")} | Select-ObjectDisplayName,MailNickname,Description,GroupID 


    # REMOVE TEAM
    # Get-Team | Where {($_.DisplayName -like "$($ENV:Username) Test Drop*")} | Select-ObjectDisplayName,MailNickname,Description,GroupID | Remove-Team


    (Get-TeamChannel -GroupId 0da77c1a-110f-42f1-8f90-dd97ff71c261).count
    #>

}