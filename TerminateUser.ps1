# ********************************************************************************
#
# Script Name: TerminateUser.ps1
# Version: 1.1
# Author: Sheridan Wendt
# Date: 9/1/2017
# Applies to: Users
#
# Description: This script performs the normal steps involved in terminating 
# access for a specific user, including: disabling in ADUC, exporting group 
# membership, removing user from groups, archiving user folders, forwarding their
# future emails, and disabling ActiveSync.
#
# Note: Skips the following protected users; CEOuser, COOuser, CIOuser, CISOuser
#
# ********************************************************************************

#Import Modules
Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

# Set Variables 
$NetAdmin = "Firstname Lastname"
$SecMgr = "Firstname Lastname"
$PathLog = "\\FileServer\Terminated Logs"
$Random = -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
$ProtectedUsers = "CEOuser", "COOuser", "CIOuser", "CISOuser"
$DTStamp = get-date -Format u | foreach {$_ -replace ":", "-"}

# Welcome Banner
Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#   Welcome to the Terminate a User Script!  #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "

#Get username to terminate and verify username isn't protected
Function Get-Username {
	$Global:Username = Read-Host "Enter username to terminate"
	if ($Username -eq $null){
		Write-Host "Username cannot be blank. Please re-enter username"
		Get-Username
	}
	$UserCheck = Get-ADUser $Username
	if ($UserCheck -eq $null){
		Write-Host "Invalid username. Please verify this is the logon id / username for the account"
		Get-Username}
    $Protected = $ProtectedUsers -contains "$Username"
	if ($Protected -eq $True){
        Write-Host "$Username is a protected user and should not be deleted. See $NetAdmin or $SecMgr for details"
        Get-Username}
}
Get-Username

#Confirm username input accuracy
$No = "n", "N", "No", "NO"
Write-Host " "
Write-Host "____________________________________________"
$Confirm = Read-Host "Are you sure you want to terminate: $Username (Y/N)"
if ($No -contains $Confirm){
        Get-Username
    }

#Set variables
$Protected = $ProtectedUsers -contains "$Username"
$UserDisabled = (Get-ADUser $Username).Enabled
$UserGroups = Get-ADPrincipalGroupMembership $Username | Select Name
$UserOU = Get-ADUser $Username | select @{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}

#Disable Active Directory account
Disable-ADAccount -Identity $Username -Confirm:$false
Write-Host "User $Username disabled"

#Set random password for user
Set-ADAccountPassword -Identity $Username -NewPassword (ConvertTo-SecureString -AsPlainText "P!1$Random" -Force)

#Export list of groups user is a Member Of
(Get-ADUser $Username).Name | Add-Content $PathLog\$Username.txt
Get-ADPrincipalGroupMembership $Username | Select Name | Add-Content $PathLog\$Username.txt
Write-Host "$Username Groups exported"

#Remove user from all groups except 'Domain Users'
Get-ADPrincipalGroupMembership -Identity $Username | where {$_.Name -notlike "Domain Users"} |% {Remove-ADPrincipalGroupMembership -Identity $Username -MemberOf $_ -Confirm:$false}
Write-Host "$Username removed from groups"

#Archive folders onto MJNAS
Move-Item -path "\\FileServer\Users\$Username" -Destination "\\FileServer\EmployeeArchive\$Username" -force
Write-Host "$Username Home Drive archived to \\FileServer\EmployeeArchive\$Username"
Move-Item -path "\\AppServer\Users\$Username" -Destination "\\FileServer\EmployeeArchive\$Username\AppName" -force
Write-Host "$Username App Drive archived to \\FileServr\EmployeeArchive\$Username\AppName"

#Get supervisor name to forward emails
Function Get-Supervisorname {
	$Global:Supervisorname = Read-Host "Enter supervisor / manager username to forward emails to"
	if ($Supervisorname -eq $null){
		Write-Host "Supervisor name cannot be blank. Please re-enter"
		Get-Username
	}
	$SuperCheck = Get-ADUser $Username
	if ($SuperCheck -eq $null){
		Write-Host "Invalid username. Please verify this is the logon id for the supervisor"
		Get-Username
	}
}
Get-Supervisorname

#Get supervisor SMTP address
$SupSMTP = (Get-ADUser $Supervisorname -Properties mail).mail

#Forward mail to supervisor
Set-Mailbox -Identity $Username -ForwardingAddress $SupSMTP
$SupName = (Get-Mailbox -identity $Username).forwardingaddress.name
Write-Host "Forwarding $Username's mail to: $SupName"

#Disable ActiveSync
set-casmailbox -identity $Username -ActiveSyncEnabled $false
$ActiveSync = (Get-casmailbox -identity $Username).activesyncenabled
Write-Host "ActiveSync Enabled: $ActiveSync"

#Remove phone extension from ipPhone attribute to improve Microcall report accuracy
set-aduser $Username -Replace @{ipPhone=" "}

#Move disabled user to Disabled OU in ADUC
Move-ADObject -Identity (Get-ADuser $Username).objectGUID -TargetPath 'OU=Disabled,OU=User,DC=domain,Dc=local'
$UserDisabled2 = (Get-ADUser $Username).Enabled
$UserGroups2 = Get-ADPrincipalGroupMembership $Username | Select Name
$UserOU2 = Get-ADUser $Username | select @{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}
$SupName2 = (Get-Mailbox -identity $Username).forwardingaddress.name
$ActiveSync2 = (Get-casmailbox -identity $Username).activesyncenabled
#Create a PST Backup of $Username's Mailbox


#Append text file to confirming actions taken
Add-Content “$PathLog\$username.txt” " "
Add-Content “$PathLog\$username.txt” "DateTime: $DTStamp"
Add-Content “$PathLog\$username.txt” "Account Enabled: $UserDisabled2"
Add-Content “$PathLog\$username.txt” "Group Membership: $UserGroups2"
Add-Content “$PathLog\$username.txt” "Extension: $ipPhone"
Add-Content “$PathLog\$username.txt” "$Username Home Drive archived to \\FileServer\EmployeeArchive\$Username"
Add-Content “$PathLog\$username.txt” "$Username App Drive archived to \\FileServer\EmployeeArchive\$Username\App Name"
Add-Content “$PathLog\$username.txt” "Forwarding $Username's email to: $SupName2"
Add-Content “$PathLog\$username.txt” "ActiveSync Enabled: $ActiveSync2"
Add-Content “$PathLog\$username.txt” "$Username moved to $UserOU2"
Add-Content “$PathLog\$username.txt” "______________________________________________________"
& “$PathLog\$username.txt”


Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#               User Terminated!             #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "

Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")