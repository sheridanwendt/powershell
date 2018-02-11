# ********************************************************************************
#
# Script Name: SMSNotifications.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/26/2017
# Applies to: SMS Messages via Email
#
# Description: This script assigns a various list of customizable messages to the 
# variable $Messages, generates a random email address (so these notifications
# cannot be blocked by the recipient), and sends the message via email to a phone
# carrier's email:sms gateway. A 30 second break is taken and then the next text
# is sent until 10 (number assigned to $MaxCount) notifications have been sent.
#
# Resource: https://en.wikipedia.org/wiki/SMS_gateway#Spreadsheet-to-SMS_gateway
#
# ********************************************************************************

$Count = 0
$MaxCount = 10
$Messages = "The Force is with you", "You are one with the Force", "You are the last Jedi", "Do or Do Not. There is no try."
$ToPhone = "1428571428"
$ToCarrier = "mms.att.net"
$Subject = "Yoda Says:"
$SMTPServer = 9.9.9.9

Do {
    $Count 
    "Count at $Count"
    "Generating random number"
    $Sender = -join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_})
    "Selecting a random message from the Messages variable"
    $Message = $Messages[(Get-Random -Maximum ([array]$Messages).count)]
    "Sending message"
    Send-MailMessage -To "$ToPhone@$ToCarrier" -From "$Sender@domain.com" -Subject "$Subject" -Body "$Message" -SmtpServer $SMTPServer
    "Message Sent"
    Start-Sleep -s 30
    }
While ($Count++ -le $MaxCount)