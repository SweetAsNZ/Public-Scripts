function Get-SubnetsWithNoSite
{
	$NetLogonLOG = 'C:\Windows\Debug\Netlogon.log'

	$originalStrings = (Get-Content $NetLogonLOG | Select-String -SimpleMatch "NO_CLIENT_SITE") 

	$stripPattern = "^\d{2}/\d{2} \d{2}:\d{2}:\d{2} \[\d{2,4}\] .{3,}: NO_CLIENT_SITE: "

	$MissingStrings = $originalStrings | ForEach-Object {
		$finalString = $_ -replace $stripPattern, ""
		$finalString
	} | Sort | Get-Unique

	$MissingStrings
	
}