function Get-SPN{
	[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string]$ComputerName
    )

	
	$ComputerName = $env:COMPUTERNAME
	cmd /c SETSPN -q */$ComputerName

	<# Expected OUTPUT
	Checking domain DC=A,DC=local
	CN=LAPTOP1,OU=IT,OU=Computers,OU=AKL,DC=A,DC=local
		CmRcService/LAPTOP1
		CmRcService/LAPTOP1.A.local
		TERMSRV/LAPTOP1.A.local
		TERMSRV/LAPTOP1
		WSMAN/LAPTOP1.A.local
		WSMAN/LAPTOP1
		RestrictedKrbHost/LAPTOP1
		HOST/LAPTOP1
		RestrictedKrbHost/LAPTOP1.A.local
		HOST/LAPTOP1.A.local

	Existing SPN found!

	#>
}