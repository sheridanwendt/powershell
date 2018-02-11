# ********************************************************************************
#
# Script Name: VMWare_RescanStorage.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 11/21/2017
# Applies to: User Folders
#
# Description: This script will instruct each host in the cluster to rescan it's  
# storage adapters for new storage devices AND for VMFS volumes on LUNs
#
# ********************************************************************************

# Set variables
$Cluster = "ClusterName"
$vCenter = "vcenter.domain.local"

# Connect to vCenter server
Connect-VIServer $vCenter

# Check the members of the cluster. For each member, rescan HBAs
Get-Cluster -Name $Cluster | Get-VMHost | Get-VMHostStorage -RescanAllHba

# Check the members of the cluster. For each member, rescan VMFS volumes
Get-Cluster -Name $Cluster | Get-VMHost | Get-VMHostStorage -RescanVmfs