# ********************************************************************************
#
# Script Name: Check vCenter for Snapshots.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 11/15/2017
# Applies to: VMs
#
# Description: This script queries vCenter to determine if any VM snapshots exist
# and sends an email if any snapshots are found. Prevents empty storage-arry level
# snapshots from being empty and unusable
#
# ********************************************************************************

#Import Modules
Add-PSSnapin vmware.vimautomation.core -ErrorAction SilentlyContinue

#Set variables
$vCenter = "vcenter.domain.local"
$ToEmail = "to@domain.local"
$FromEmail = "from@domain.local"
$Subject = "VMWare Snapshots Exist"
$Body = "A scheduled check has determined that a snapshot exists on vCenter. The VM snapshot details are below: `n `n$VM `n$VMname `n$VMdesc `n$VMcrtd `n$VMsize"
$SMTPServer = "9.9.9.9"

#Connect to vCenter
Connect-VIServer $vCenter

#Query vCenter
$Snapshots = Get-VM | Sort | Get-Snapshot | Select VM, Name, Description, Created, SizeGB
$VM = Get-VM | Sort | Get-Snapshot | Select VM
$VMname = Get-VM | Sort | Get-Snapshot | Select Name
$VMdesc = Get-VM | Sort | Get-Snapshot | Select Description
$VMcrtd = Get-VM | Sort | Get-Snapshot | Select Created
$VMsize = Get-VM | Sort | Get-Snapshot | Select SizeGB

#Send email if snapshots exist
if ($Snapshots -eq $null) {}
else {
    Send-MailMessage -To "$ToEmail" -From "$FromEmail" -Subject "$Subject" -Body "$Body" -SmtpServer $SMTPServer
}