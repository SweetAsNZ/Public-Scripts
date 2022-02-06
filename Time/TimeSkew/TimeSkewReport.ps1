# REF: https://gallery.technet.microsoft.com/scriptcenter/Capture-Time-Skew-Report-25512e60

<# This script is prepared by Subhro Majumder on 20-July-2018, and modified on 01-June-2018.#>
<# This script has been tested in PowerShell 4.0#>
<# You have to modify this script in some area.#>
<# You can incorporate this script with Windows Task scheduler.#>


$date=Get-Date
$date1= $date.ToString("yyyymmdd")+ "-"+$date.ToString("HHmm")
$path= "C:\Scripts\TimeSkew" <# Please modify the path as required #>

$directory= New-Item -ItemType directory -Path "$path\$date1"
$Report= w32tm /monitor > $directory\TimeSkewReport.txt
$File= "$directory\TimeSkewReport.txt"

<# Please modify the body text as per your requirement.#>
$bodyText=
@'
Hi Team,
Please find attached the Time Skew Report for <Domain Name> Domain
This is an auto generated mail. Please do not reply.


Regards,
IT Team

'@

       
# Please enter SMTP server name
$smtpServer = "<SMTP Server FQDN>"
# Creating a Mail object
$msg = new-object Net.Mail.MailMessage
# Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

# Email structure
$msg.From = "servername@domainname.com" # This should be in email address format.
$msg.To.Add("Recepient Email Address / DL") # Please add Recepient Email Address / DL
$msg.To.Add("Recepient Email Address / DL") # Please add additional Recepient Email Address / DL
$msg.subject = "Time Skew Report: <Domain Name> Domain"
$msg.body = $bodyText

$att = new-object Net.Mail.Attachment($File)
$msg.Attachments.Add($att) 
   
# Sending email
$smtp.Send($msg) 