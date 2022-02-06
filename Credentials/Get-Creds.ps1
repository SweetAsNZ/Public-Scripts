function Get-Creds{

    <#
.SYNOPSIS
Get Credentials from the previously save output of Set-Creds.ps1
The file is only valid for your user name on the computer that created the Set-creds.ps1 output file.

.DESCRIPTION
For use in scripts that is more secure than Get-Credential.
Beware if script logging is on on the machine that runs the Set-Creds as the password may be logged in a transcript or event log.

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
N/A
.OUTPUTS
Log File
.EXAMPLE
Enter-PSSession -ComputerName Server1 -Credential $Cred
.LINK
https://www.sans.org/blog/using-vmware-powercli-modules-measure-vmware-compliance/
#>

    $Key = Get-Content "$($env:USERPROFILE)\.sec\KeyFile"
    $EncryptedPwd = Get-Content "$($env:USERPROFILE)\.sec\ScriptP.sec"

    $Cred = New-Object System.Management.Automation.PSCredential -ArgumentList "$ENV:USERDOMAIN\$ENV:USERNAME",`
    ($EncryptedPwd | ConvertTo-SecureString -Key $Key)

}