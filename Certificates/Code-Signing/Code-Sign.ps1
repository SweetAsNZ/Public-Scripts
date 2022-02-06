# WIP

#Set-AuthenticodeSignature 
$Cert = (Get-ChildItem Cert:CurrentUser\My\ -CodeSigningCert)

Get-Childitem Cert:\CurrentUser\TrustedPublisher
Get-Childitem Cert:\CurrentUser\Disallowed

#Get-AuthenticodeSignature

#script to sign save as a separate file
$yourName = Read-Host "What is your name?"
Write-Host "Hello $yourName"

