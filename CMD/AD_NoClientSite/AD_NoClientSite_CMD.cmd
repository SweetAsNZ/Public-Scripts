SET LOG=NO_CLIENT_SITE.log

CD C:\Temp
COPY /Y C:\Windows\Debug\Netlogon.log .\

TYPE .\Netlogon.log | FINDSTR /I "NO_CLIENT_SITE" > .\%LOG%

