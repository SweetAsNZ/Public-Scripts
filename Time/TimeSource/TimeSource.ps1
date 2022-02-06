$PDC = (Get-ADDOmain).PDCEmulator
#$PDC = "ads-dctl01-lata.A.local"

w32tm /query /computer:$PDC /source 
w32tm /query /computer:$PDC /configuration 
w32tm /query /computer:$PDC /peers 
w32tm /query /computer:$PDC /status 
#w32tm /query /computer:$PDC /verbose
