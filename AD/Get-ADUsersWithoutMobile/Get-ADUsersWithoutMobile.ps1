# ADUsers With No Mobile
$Output = "C:\Temp\ADUsers_WithNoMobile.csv"

Get-ADUser -Filter * -Properties * | Where-Object {$_.Mobile -eq $NUll} |
 Select-Object name,sAMAccountName,givenName,sn,mail,employeeType,company,Department,@{n='OU';e={$_.distinguishedname -replace "CN=$($_.cn),",""}} |
  Sort-Object Name | Export-Csv -NoTypeInformation $Output