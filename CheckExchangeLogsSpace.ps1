# ********************************************************************************
#
# Script Name: CheckExchangeLogsSpace.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/26/2017
# Applies to: Exchange Server
#
# Description: This script will retrieve the amount of free space remaining on any  
# disk, specified by letter, on any computer or server, specified by it's name
# Then an email will be sent to the address specified including the space details  
#
# ********************************************************************************

# Set variables 
$Server = "Exchange"
$DriveLetter = "L:"
$FromEmail = "from@domain.com"
$ToEmail = "to@domain.com"
$Subject = "Exchange Logs Space"
$Body = "Team, `n `nHere are the most recent drive statistics for the Exchange Logs volume `n $DriveStats `n `nRegards, `nNeighborhood Friendly Scripterman `n"
$SMTPServer = "192.168.1.1"

# Get the sizes and free space of all disks
$DriveStats = gwmi win32_logicaldisk -ComputerName $Server -Filter "DeviceId='$DriveLetter'" | Format-Table DeviceId, MediaType, @{n="Size";e={[math]::Round($_.Size/1GB,2)}},@{n="FreeSpace";e={[math]::Round($_.FreeSpace/1GB,2)}} | Out-String

# Send warning email  
Send-MailMessage -From "$FromEmail" -To "$ToEmail" -Subject "$Subject" -Body "$Body" -SmtpServer $SMTPServer