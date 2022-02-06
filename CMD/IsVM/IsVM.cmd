:: FileName: isVM.cmd
 
 
:: ********* AUTHOR**************************
:: 
:: Author:  Tim West (Corp IT)
:: Create Date: 3:47 p.m. 23/09/2011
::
:: *******************************************
 
 
:: ********* PURPOSE  ************************
:: Purpose: Shows if a local machine is a VM
::	Will say "VMware-"... or Hyper-V or Xen
:: Dependencies: 
:: *******************************************
 
 
:: ********  NOTES  **************************
:: Notes: 
:: *******************************************
 
 
:: *********  MODIFIED  **********************
:: Modified Date: 1:48 p.m. 12/01/2012
:: Modified By: Tim West
:: Reason: Added Echo
::
::
:: Modified Date: 
:: Modified By: 
:: Reason: 
::
:: *******************************************
::
::
ECHO it will say VMWare or Hyper-V or Xen if it is one of those 
ECHO. 

wmic bios get serialnumber
PAUSE
