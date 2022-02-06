# Run this before renewing the Subordinate Certificate Authority Certs otherwise you'll get a certificate valid for 1 year

$KeyLength = 256 #4096
$SubCAYears = 10


Write-Host "Writing CAPolicy.inf file to the Windows directory"
$CAPolicyContent = '[Version]' + "`r`n"
$CAPolicyContent += 'Signature="$Windows NT$"' + "`r`n" + "`r`n"
$CAPolicyContent += '[Certsrv_Server]' + "`r`n"
$CAPolicyContent += 'RenewalKeyLength=' + $KeyLength + "`r`n"
$CAPolicyContent += 'RenewalValidityPeriod=Years' + "`r`n"
$CAPolicyContent += 'RenewalValidityPeriodUnits=' + $SubCAYears + "`r`n"
$CAPolicyContent += 'LoadDefaultTemplates=0' + "`r`n"
$CAPolicyContent | Out-File -FilePath C:\Windows\CAPolicy.inf -Encoding ascii -Force
PAUSE

# To increase the validity period of the Subordinate CA Certificate, on the Offline Root CA and issue the following commands. 
# Without this the SubCA Cert renewal will result in a 1 year cert 
certutil -setreg ca\ValidityPeriod "Years"
certutil -setreg ca\ValidityPeriodUnits "10"

<#
OUTPUT:
PS C:\SCRIPTS\DSC\ADS-CERT01-LAPD> certutil -setreg ca\ValidityPeriod "Years"
certutil -setreg ca\ValidityPeriodUnits "10"
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA NAME>\ValidityPeriod:

Old Value:
  ValidityPeriod REG_SZ = Years

New Value:
  ValidityPeriod REG_SZ = Years
CertUtil: -setreg command completed successfully.
The CertSvc service may need to be restarted for changes to take effect.
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\<CA NAME>\ValidityPeriodUnits:

Old Value:
  ValidityPeriodUnits REG_DWORD = 1

New Value:
  ValidityPeriodUnits REG_DWORD = a (10)
CertUtil: -setreg command completed successfully.
The CertSvc service may need to be restarted for changes to take effect.
#>
Restart-Service CertSvc
