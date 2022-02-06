:: FileName: IP_Route_ARP.cmd
::
:: Title: IP Route ARP WinFW

@ECHO OFF 
 
:: ***********************************
:: 
:: Author:  Tim West (Sweet As Chocolate Ltd)
:: Create Date: 9:18 a.m. 30/01/2013
:: Version: 1.0 R
:: 
:: (D= Draft, R = Released, F = Final)
:: *******************************************
 
 
:: ********* PURPOSE  ************************
:: Purpose: to output IPCOnfig /all, ARP -a, Route Print & WinFW Rules to a txt file for future reference purposes.  
:: To be done for all networking changes pre and post CR.
::
:: Dependencies: None
:: *******************************************
 
 
:: ********  NOTES  **************************
:: Notes: 
:: *******************************************
 
 
:: *********  MODIFIED  **********************
:: Modified Date: 9:29 a.m. 18/03/2013
:: Modified By: Tim West (Corp IT)
:: Reason: Added Windows Firewall Dump
::
:: Modified Date: 
:: Modified By: 
:: Reason: 
::
:: *******************************************
:: 


route print > C:\Route.txt
route print > "C:\route_%date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%_%time:~6,2%.txt"

ipconfig /all > C:\ipconfig.txt
ipconfig /all > "C:\ipconfig_%date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%_%time:~6,2%.txt"

arp -a > C:\Arp.txt
arp -a > "C:\Arp_%date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%_%time:~6,2%.txt"

netsh advfirewall firewall show rule name=all > C:\WinFW_Rules.conf
netsh advfirewall firewall show rule name=all > "C:\WinFW_Rules_%date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%_%time:~6,2%.conf"