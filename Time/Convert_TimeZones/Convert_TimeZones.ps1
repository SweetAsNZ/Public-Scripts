#REF: https://www.craigforrester.com/posts/convert-times-between-time-zones-with-powershell/
#REF: https://virtuallysober.com/2020/01/16/changing-date-time-zones-using-powershell/ (Not used but cool)

# Convert Date Time to another Timezone
$SRC = 'India'
$DST = 'AUS Eastern'
$time_to_convert = '2020-11-09T13:30:00'

# List TimeZones - Comment the following 33 lines after first run
$outputTZs = $env:USERPROFILE+'\Documents\Timezones.txt'
Get-TimeZone -ListAvailable | Select ID | Out-File $outputTZs 
#Get-TimeZone -ListAvailable | Select Displayname | Out-File $outputTZs 
Notepad $outputTZs


# Source Time time zone info to a variable
$SrcTZ = [System.TimeZoneInfo]::GetSystemTimeZones() |`
Where-Object { $_.ID -match $SRC }

# Destination time zone info to a variable
$DstTZ = [System.TimeZoneInfo]::GetSystemTimeZones() |`
Where-Object { $_.Id -match $DST }

[System.TimeZoneInfo]::ConvertTime($time_to_convert, $SrcTZ, $DstTZ)

