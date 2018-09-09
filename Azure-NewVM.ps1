# ********************************************************************************
#
# Script Name: Azure-NewVM.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/5/2018
# Applies to: Azure virtual machines
#
# Description: Create a new Virtual Machine in Azure with a prompt to set the new 
# VM's local administrator credentials 
#
# ********************************************************************************

# Set variables
## Global
$ResourceGroupName = "RG2"
$Location = "SouthCentralUS"

## Compute
$VMName = "DC01"
$ComputerName = "DC01"
$VMSize = "Standard_B1ms"
$OSDiskName = "$ComputerName" + "_OSDisk"

## Storage
$Random = -join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_})
###The random variable is configured here because your Storage Account Name must be unique across Azure 
$StorageAccountName = "Storage" + $VMName + "$Random"
$StorageAccountName = $StorageAccountName.ToLower()
$StorageType = "Standard_GRS"
###type options currently include Premium_LRS, Standard_GRS, Standard_LRS, Standard_RAGRS, Standard_ZRS
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Type $StorageType -Location $Location

## Network
$InterfaceName = "NIC" + $VMName
$Subnet1Name = "Subnet1"
$VNetName = "VNet" + $VMName
$VNetAddressPrefix = "10.1.0.0/16"
$VNetSubnetAddressPrefix = "10.1.1.0/24"

# Actions
## Create Public New IP
$pIP = New-AzureRmPublicIpAddress -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic

## Create a Subnet Configuration
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix

## Create a Virtual Network
$VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig

## Create a NIC
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $pIP.Id

## Create OS credentials
$Credential = Get-Credential

## Create Virtual Machine
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine
