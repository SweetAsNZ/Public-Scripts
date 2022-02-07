# Script to copy the most recent file containing a certain string from one folder to another folder on a Windows machine.

Copy-Item (Get-ChildItem -Path C:\Temp -File -Name *.txt | Get-Content | Where {$_ -like "*cat*"} | Select -First 1).PSPath -Destination C:\Temp\Folder2

