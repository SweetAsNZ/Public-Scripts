# https://social.technet.microsoft.com/Forums/windows/en-US/fb7ceef5-0048-4e80-826e-730cb3744c48/powershell-counting-all-ad-departments?forum=ITCG
# Get a Unique List of Departments from AD

$Output = "C:\SCRIPTS\AD\Department\Department_Count.txt"

if (!(Test-Path -Path $Output) ){

    # Create a directory if it doesn't exist based on the $Output minus the file name
    New-Item (Split-Path -Path $Output -Parent) -ItemType Directory
}

$Dept = Get-ADUser -Filter * -Properties Department -ResultSetSize 100000 | Where-Object {($_.Enabled -eq $true)} |
 Group-Object Department | Select-Object Name,Count | Sort-Object -Descending Count,Name 
$Dept | Out-File $Output