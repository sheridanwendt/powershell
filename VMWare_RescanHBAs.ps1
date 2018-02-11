# ********************************************************************************
#
# Script Name: VMWare_RescanHBAs.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 11/21/2017
# Applies to: User Folders
#
# Description: This script will instruct each host in a cluster to rescan it's  
# Host Bus Adapters (HBAs) for new storage devices
#
# ********************************************************************************

# Use set variables in environments with one vCenter server
$Cluster = "ClusterName"
$vCenter = "vcenter.domain.local"

# Or prompt user for variables in environments with multiple vCenter servers
# $Cluster = Read-Host "Cluster Name"
# $vCenter = Read-Host "vCenter Server FQDN"

# Connect to vCenter server
Connect-VIServer $vCenter

# Check the members of the cluster. For each member, rescan HBAs
Get-Cluster -Name $Cluster | Get-VMHost | Get-VMHostStorage -RescanAllHba