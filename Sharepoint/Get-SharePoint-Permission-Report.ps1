function Get-SharePoint-Permission-Report{

    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$CompanyName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$OutputPath
    )

    # SPO-specific cmdlets require sharepoint-online module

    if(!(Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)){
        Install-Module -Name Microsoft.Online.SharePoint.PowerShell
    }
    Import-Module -Name Microsoft.Online.SharePoint.PowerShell

    $Date = (Get-Date).ToString("s").Replace(":","-")   # _$($Date).csv    # Date for use in Filenames

    # Only useful if running from the ISE interactively
    if(!($CompanyName)){
        
        $CompanyName  = "Microsoft_ChangeMe"
    }

    if(!($OutputPath)){
        
        $OutputPath = "C:\Temp\SPO_PermissionsReport_$($CompanyName)_$($Date).csv"
    }

    [string]$AdminURlSuff = "-admin.sharepoint.com"
    [string]$ServiceURL   = "https://" + $CompanyName + $AdminURlSuff

    [string]$URL  = "https://" + $CompanyName + ".sharepoint.com"
    

    if(!(Get-Creds)){
        
        Write-Output "Using insecure Get-Credential"
        $Cred =  Get-Credential

        #Connect to SharePoint Online
        Connect-SPOService -Url $ServiceURL -Credential $Cred
    }

    if(Get-Creds){
        
        Write-Output "Using Secure Credential file"
        $Cred =  Get-Creds

        #Connect to SharePoint Online
        Connect-SPOService -Url $ServiceURL -Credential $Cred
    }

    #Generating Report
    $GroupsData = @()

    #get sharepoint online groups powershell
    $SiteGroups = Get-SPOSiteGroup -Site $URL

    ForEach($Group in $SiteGroups) {

        $GroupsData += New-Object PSObject-Property @{

            'Group Name'  = $Group.Title
            'Permissions' = $Group.Roles -join ","
            'Users'       = $Group.Users -join ","

        }
    }

    #Export the data to CSV
    $GroupsData | Export-Csv $OutputPath -NoTypeInformation

}