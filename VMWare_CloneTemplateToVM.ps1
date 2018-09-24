<#
Name: VMWare-CopyVMTemplate.ps1
Version: 1.0
Author: Sheridan Wendt
Date: 9/5/2018
Applies to: Workstations
Description: 
-Get a list of employees with a specific job title
-Check the application directory of each employee in the list to determine their workstation's FQDN
-Check the workstation for an application directory to ensure the application is installed
#>

# Define Global Variables
$Cluster = "ClusterName"
$vCenter = "vCenter.domain.local"

# Connect to environment
Connect-VIServer $vCenter

# Define Global Variables
$ResourecePool = Get-View -ViewType ResourcePool -Property Name
$Templates = Get-Template | Sort | Select Name
$Hosts = Get-VMHost | Sort | Select Name
$Datastores = Get-Datastore | Sort | Select Name

# Choose parameters
Function Choose-Parameters {
    # Choose Template
    $Templates
    Write-Host " "
    $Global:Template = Read-Host "Choose a template from above"
    # Choose Host
    $Hosts
    $Global:VMHostString = Read-Host "Choose a Host from above"
    $Global:VMHost = Get-VMHost -Name $VMHostString
    # Choose Datastore
    $Datastores
    Write-Host " "
    $Global:Datastore = Read-Host "Choose a Datastore from above"
    # Choose a Name
    Write-Host " "
    $Global:Name = Read-Host "Choose a Name for the new VM"
    # Choose a Disk Storage Format
    Write-Host " "
    Write-Host "EagerZeroedThick"
    Write-Host "Thick"
    Write-Host "Thick2GB"
    Write-Host "Thin"
    Write-Host "Thin2GB"
    $Global:DiskStorageFormat = Read-Host "Chose a Disk Storage Format from above"
}
Choose-Parameters

Function Confirm-Parameters {
    Write-Host "______________________________________"
    Write-Host "Confirm New VM Configuration"
    Write-Host "Template: $Template"
    Write-Host "Host: $Host"
    Write-Host "Datastore: $Datastore"
    Write-Host "Name: $Name"
    Write-Host "______________________________________"
    $Confirmation = Read-Host "Is this accurate (Y/N)?"
    $No = "n", "N", "No", "NO"
    if ($No -contains $Confirm){
        Choose-Parameters
    }
}
Confirm-Parameters

# Copy Template to VM
New-VM -Template $Template -Host $VMHost -Datastore $Datastore -Name $Name -DiskStorageFormat $DiskStorageFormat
