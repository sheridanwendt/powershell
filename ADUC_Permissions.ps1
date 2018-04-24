# ********************************************************************************
#
# Script Name: ADUC_Permissions.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 6/1/2016
# Applies to: Users
#
# Description: This script generates a list of all users in Active Directory and
# the security groups those users are members of. Then list is emailed to the 
# appropriate team, such as security or compliance, for review.
#
# ********************************************************************************

# Import modules
Import-Module Activedirectory

# Set variables
$date = Get-Date -UFormat "%Y-%m-%d"
$ReportPath = "\\FileServer\Reports"
$ReportName = $date

# Get a list of users and their groups
Get-ADUser -Filter * -Properties DisplayName,memberof | % {
  New-Object PSObject -Property @{
	UserName = $_.DisplayName
	Groups = ($_.memberof | Get-ADGroup | Select -ExpandProperty Name) -join ","
	}
} | Select UserName,Groups | sort UserName | Export-Csv -path "$ReportPath\$ReportName-ADUCPermissions.csv" -NTI

# Set email variables
$SMTPServer = "9.9.9.9"
$From = "InfoSec@doman.com"
$To = "team@domain.com"
$Subject = "Monthly User Permissions Report"
$Body = @"
Team,

The Monthly User Permissions Report is ready and available for viewing at: 
"$ReportPath\$ReportName-ADUCPermissions.csv"

The Monthly User Permissions Report shows all domain users and every Security Group and Distrubution Group that user is a member of. 

Thanks!
InfoSec Team
"@

# Send the email 
Send-MailMessage -From "$From" -To "$To" -Subject "$Subject" -Body "$Body" -smtpServer $SMTPServer