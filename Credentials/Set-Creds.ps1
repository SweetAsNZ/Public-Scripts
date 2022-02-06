function New-Credential{
<#
.SYNOPSIS
Set Credentials for use with Get-Creds function e,g. Get-Creds.ps1.
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
OutputPath
SecurePWFileName
.PARAMETER Extension
N/A
.INPUTS
Mandatory: You are prompted for your Credentials.

Not Mandatory: OutputPath, SecurePWFileName.
.OUTPUTS
Log File
.EXAMPLE
New-Credential
.LINK
https://www.sans.org/blog/using-vmware-powercli-modules-measure-vmware-compliance/
#>  
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$OutputPath,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()] 
        [string]$SecurePWFileName
        
    )

    # Ref: https://www.sans.org/blog/using-vmware-powercli-modules-measure-vmware-compliance/

    $UserName = ($env:UserDomain + "\" + $env:USERNAME)

    if(!($OutputPath)){
        $OutputPath = "$($env:USERPROFILE)\.sec"
    }
    if(!($SecurePWFileName)){
        $SecurePWFileName = "ScriptP.sec"
    }

    if (-Not (Test-Path $OutputPath) ) {
        New-Item -ItemType Directory $OutputPath # Create SECURE Folder if it doesn't exist
    }

    # Set Credentials
    Try{
        
        $Cred = Get-Credential -UserName "$ENV:USERDOMAIN\$ENV:USERNAME" -Message "Password?"

        <# Next, you can create a symmetric key file to be used to encrypt your password. 
        Use the .NET cryptographic random number generator to build a key of an appropriate size - 256 bits in this example. 
        Be sure that you set the permissions on the key file so that only authorized users can read it, since it will be used to decrypt your password!
        #>

        # Create a new key byte array and fill it
        $Key = New-Object Byte[] 16
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        
        #Send to the key file</p>
        
        if(!("$($OutputPath)\keyFile")){
            $Key | Out-File "$($OutputPath)\KeyFile"
        }
        
        if(!("$($OutputPath)\ScriptP")){
            try{
                
                $Cred.Password | ConvertFrom-SecureString -Key $Key | Out-File "$($OutputPath)\$SecurePWFileName"
                Write-Output "`r`n Check Permissions Are Suitable Here: $($OutputPath)\$SecurePWFileName `r`n"
            }
            catch{
                
                Write-Error "FAILED Creating $($OutputPath)\$SecurePWFileName"
            }
        }#END IF
    }
    Catch{
        
        Write-Output 'RUN THIS: "$Credential = Get-Credential -UserName $UserName -Message Password? And re-open Powershell" '
        #Write-Output 'AND THIS: "$Credential.Password | ConvertFrom-SecureString | Out-File $OutputPass" ' # Only Required for Initial Creation
        Write-Output ' Refer to these credentials via: 
        
        $Key          = Get-Content "$OutputPath\KeyFile"
        $EncryptedPwd = Get-Content "$OutputPath\ScriptP"
        
        $Cred = New-Object System.Management.Automation.PSCredential -ArgumentList "$ENV:USERDOMAIN\$ENV:USERNAME",`
          ($encryptedPwd | ConvertTo-SecureString -Key $Key)
        
        e.g.  Enter-PSSession -ComputerName Server1 -Credential $Cred'

    }#END BIG TRY/CATCH
}
