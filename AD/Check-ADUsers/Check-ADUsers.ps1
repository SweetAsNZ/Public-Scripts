Get-Aduser -Filter * -Properties * | Sort-Object Name | 
FT -Auto Name,Description,OfficePhone,MobilePhone,PasswordNeverExpires,AccountExpires