:: FileName: CreateSparseFile.cmd
 
 
:: ********* AUTHOR**************************
:: 
:: Author:  Tim West (Sweet As Chocolate)
:: Create Date: 5:25 a.m. 1/09/2011
::
:: *******************************************
 
 
:: ********* PURPOSE  ************************
:: Purpose: To create a sparse file to be deleted in case of emergency
::
:: Dependencies: 
:: *******************************************
 
 
:: ********  NOTES  **************************
:: Notes: 
:: *******************************************
 
 
:: *********  MODIFIED  **********************
:: Modified Date: 5:46 a.m. 1/09/2011
:: Modified By: Added EventCreate (Tim@Sweet As Chocolate)
:: Reason: 
::
:: Modified Date: 9:16 AM 11/11/2011
:: Modified By: Increased to 1 GB
:: Reason: 


:: Modified Date: 
:: Modified By: 
:: Reason: 
:: *******************************************
 
ECHO Create a 1,000 MB File
ECHO. 
PAUSE


ECHO %date:~10,4%%date:~7,2%%date:~4,2%_%time:~0,2%%time:~3,2%_%time:~6,2% %username% >> C:\scripts\SparseFileCreate.log

:: This is in Bytes.  1024100000 = 1 GB
FSUTIL file createnew .\_DELME.txt 4096400000 >> C:\scripts\SparseFileCreate.log

ECHO. >> C:\scripts\SparseFileCreate.log
ECHO **************** >> C:\scripts\SparseFileCreate.log

EVENTCREATE /l SYSTEM /SO SPARSE_FILE /T WARNING /id 976 /d "CreateSparseFile.cmd has been run to create a sparse file of 4 GB.  These sparse files are to be deleted in time of disk space shortage."

PAUSE