# ********************************************************************************
#
# Script Name: HomeDriveCleanup.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/11/2017
# Applies to: Folders
#
# Description: This script queries Active Directory for a list of disabled users
# then checks a root folder, such as a directory containing user folders 
# and if there is a folder name that matches a user in the disabled list it gets 
# archived. The process is repeated if there is a directory defined for the 
# $AppRoot variable. If a folder gets archived an entry is added to a log.
#
# ********************************************************************************

#Set variables
$HomeRoot = "\\FileServer\users"
$AppRoot = "\\AppServer\Users"
$HomeArchive = "\\FileServer\HomeArchive"
$AppArchive = "\\FileServer\AppArchive"
$list = (Search-ADAccount –AccountDisabled -UsersOnly).SamAccountName
$HomeDriveCleanupLog = "\\FileServer\HomeArchive\log.txt"

#Archive folders of disabled users and log
foreach($User in $List)
{
    $DTStamp = get-date -Format u | foreach {$_ -replace ":", "-"}
    $Path = Join-Path $HomeRoot -childpath $User
    Move-Item $Path $HomeArchive -Force
    Add-Content "$HomeDriveCleanupLog" "$DTStamp | $User's Home Drive archived to $Path"
    $Path2 = Join-Path $AppRoot -childpath $User
    Move-Item $Path2 $AppArchive -Force
    Add-Content "$HomeDriveCleanupLog" "$DTStamp | $User's App Drive archived to $Path2"
    Add-Content "$HomeDriveCleanupLog" "_______________________________________________________________________________________"
}