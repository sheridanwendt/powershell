# ********************************************************************************
#
# Script Name: New_User.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/15/2017
# Applies to: Users
#
# Description: This script performs the normal steps involved in creating a new
# user, including: copying user in active directory, assigning group membership, 
# creating a home drive folder, setting permissions, creating an application
# folder, setting permissions creating a folder based on the department the user 
# is in, settings permissions, assigning gender in active directory, assigning
# group(s) based on gender in active directory, assigning a manager, assigning a 
# state, assiging a phone extension in active directory, puting the user in the 
# correct OU in active directory, creating an exchange mailbox using the storage 
# group with the most free space, handle errors and log the actions taken
#
# ********************************************************************************

#Import Modules ******************************************************************
Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

#Set global variables ************************************************************
#Set date-time stamp format
$DTStamp = get-date -Format u | foreach {$_ -replace ":", "-"}
# Set Company department variables 
$Departments = "Accounting", "Administration", "Compliance", "Directors", "Executives", "IT", "Legal", "Operations", "Other"
$Department1 = "Administration"
$Department2 = "Compliance"
$Department3 = "Directors"
$Department4 = "Executives"
$Department5 = "IT"
$Department6 = "Legal"
$Department7 = "Operations"
$Department8 = "Others"
#User's home folder where they will store personal files
$HomePath = "\\HomeFolderPath\Users"
#Optional folder for use by an application when each users needs a folder for that application
$AppPath = "\\ApplicationPath\Users"
#Distribution Group for Men
$Men = [ADSI]"LDAP://cn=Men,ou=Distribution Groups,ou=Groups,dc=domain,dc=local"
#Distribution Group for Women
$Women = [ADSI]"LDAP://cn=Women,ou=Distribution Groups,ou=Groups,dc=domain,dc=local"
#Default user password
$PlainPassword = "DefaultPassword1"
$Password = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
#Default domain controller 
$Server = "DomainController.Domain.local"
#Default Exchange server
$Exchange = "EX01"
#States company has offices in
$States = “AL”, “ AK”, “ AZ”, “ AR”, “ CA”, “ CO”, “ CT”, “ DE”, “ FL”, “ GA”, “ HI”, “ ID”, “ IL”, “ IN”, “ IA”, “ KS”, “ KY”, “ LA”, “ ME”, “ MD”, “ MA”, “ MI”, “ MN”, “ MS”, “ MO”, “ MT”, “ NE”, “ NV”, “ NH”, “ NJ”, “ NM”, “ NY”, “ NC”, “ ND”, “ OH”, “ OK”, “ OR”, “ PA”, “ RI”, “ SC”, “ SD”, “ TN”, “ TX”, “ UT”, “VT”, “VA”, “WA”, “WV”, “WI”, “ WY”
#Log path for each time this script runs:
$LogPath = "\\ScriptLogPath\New Hire Logs"

#Get user variables ***************************************************************
Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#  Welcome to the Create a New User Script!  #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "
$FirstName = Read-Host "First Name"
$LastName = Read-Host "Last Name"
$FullName = $FirstName + " " + $LastName
$Email = "$FirstName.$LastName@domain.com"

#Get username to create and verify username isn't taken ***************************
Function Get-Username {
	$Global:Username = Read-Host "Username"
	if ($Username -eq $null){
        Write-Host "__________________________________________________"		
        Write-Host "Username cannot be blank. Please re-enter username"
		Get-Username
	}
    $TakenUsers = (get-aduser -Filter *).samaccountname
    $Taken = $TakenUsers -contains "$Username"
	if ($Taken -eq $True){
        Write-Host "_______________________________________"
        Write-Host "$Username is taken. Please try another."
        Get-Username
    }
}
Get-Username

#Confirm username input accuracy **************************************************
$No = "n", "N", "No", "NO"
Write-Host " "
Write-Host "____________________________________________"
$Confirm = Read-Host "Is this username accurate: $Username (Y/N)"
if ($No -contains $Confirm){
        Get-Username
    }

#Get Gender and verify proper input **********************************************
Function Get-Gender {
	$Global:Gender = Read-Host "Gender (M/F)"
	if ($Gender -eq $null){
    Write-Host "_____________________________________________________________"		
    Write-Host "Gender cannot be blank. Please re-enter gender."
    Write-Host " "
		Get-Gender
	}
    $Genders = "M", "F", "m", "f"
    $GenderTest = $Genders.contains($Gender)
	if ($GenderTest -eq $False){
        Write-Host "_______________________________________"
        Write-Host "'$Gender' is not an option. Please enter 'm' or 'f'"
        Write-Host " "
        Get-Gender}
}
Get-Gender

#Assign phsyical office location *************************************************
Write-Host "Please choose state from the list below:"
Write-Host "----------------------------------"
Write-Host “AL,  AK,  AZ,  AR,  CA,  CO,  CT,  DE,  FL,  GA,  HI,  ID,  IL,  IN,  IA,  KS,  KY,  LA,  ME,  MD,  MA,  MI,  MN,  MS,  MO,  MT,  NE,  NV,  NH,  NJ,  NM,  NY,  NC,  ND,  OH,  OK,  OR,  PA,  RI,  SC,  SD,  TN,  TX,  UT, VT, VA, WA, WV, WI,  WY”
Write-Host " "
Function Get-State {
	$Global:State = Read-Host "State this user will work from"
	if ($State -eq $null){
    Write-Host "_______________________________________________"		
    Write-Host "State cannot be blank. Please re-enter state."
    Write-Host " "
		Get-State
	}
    $StateValue = $States.contains($State)
	if ($StateValue -eq $False){
        Write-Host "_______________________________________"
        Write-Host "'$State' is not an option. Please try again."
        Write-Host " "
        Get-State
    }
}
Get-State

#Display acceptable department input ********************************************
Write-Host " "
Write-Host "Departments:"
Write-Host "---------------------------"
Write-Host "-$Department1"
Write-Host "-$Department2"
Write-Host "-$Department3"
Write-Host "-$Department4"
Write-Host "-$Department5"
Write-Host "-$Department6"
Write-Host "-$Department7"
Write-Host "-$Department8"
Write-Host " "

#Get Department and verify correct spelling *************************************
Function Get-Department {
	$Global:Department = Read-Host "Please Choose a Department"
	if ($Department -eq $null){
		Write-Host "Department cannot be blank. Please re-enter department."
		Get-Department
	}
    $DeptCheck = $Departments -contains "$Department"
	if ($DeptCheck -eq $False){
        Write-Host "_____________________________________________________________"
        Write-Host "'$Department' is not a department. Please re-enter department."
        Get-Department}
}
Get-Department

#Get Manager and verify correct spelling ****************************************
Function Get-Manager {
	$Global:Manager = Read-Host "Manager"
	if ($Manager -eq $null){
		Write-Host "Manager cannot be blank. Please re-enter Manager."
		Get-Manager
	}
    $AllUsers = (get-aduser -Filter *).samaccountname
    $ManagerExists = $AllUsers -contains "$Manager"
	if ($ManagerExists -eq $False){
        Write-Host "_______________________________________"
        Write-Host "$Manager does not exist or manager's username is incorrect. Please try another."
        Get-Manager
    }
}
Get-Manager

#Get job title for new user *****************************************************
$JobTitle = Read-Host "Job Title"

#Display info message for choosing a peer ***************************************
Write-Host "_____________________________________________________________"
Write-Host "Please select a user acount to copy."
Write-Host "Please note that the new user will be in the same groups as the user you copy."
Write-Host " "

#Get peer user to copy and verify user exists ***********************************
Function Get-Peer {
	$Global:Peer = Read-Host "Peer Username to Copy"
	if ($Peer -eq $null){
    Write-Host "_____________________________________________________________"		
    Write-Host "Peer username cannot be blank. Please re-enter peer username"
		Get-Peer
	}
    $ExistingPeers = (get-aduser -Filter *).samaccountname
    $Exists = $ExistingPeers -contains "$Peer"
	if ($Exists -eq $False){
        Write-Host "_______________________________________"
        Write-Host "'$Peer' does not exist or cannot be found. Please try another."
        Get-Peer}
}
Get-Peer
$PeerGroups = (Get-ADPrincipalGroupMembership $Peer).name

#Get phone extension ************************************************************
$ipPhone = Read-Host "Extension"

#Copy new user from defined 'Peer' and set attributes ***************************
New-ADUser -Instance $Peer -SamAccountName $Username -GivenName $FirstName -Surname $LastName -Name $Fullname -DisplayName $Fullname -UserPrincipalName $Username@domain.local -AccountPassword $Password -HomeDirectory "$HomePath\$Username" -Department $Department -State $State -Enabled $True -Server $Server
Set-ADUser $Username -Server $Server -Replace @{ipPhone="$ipPhone"}
Set-ADUser $Username -Server $Server -Replace @{title="$JobTitle"}
foreach ($Group in $PeerGroups | Where-Object {$_ -ne "Domain Users"})
{
	Add-ADGroupMember -Identity "$Group" -Members $Username -ErrorAction Ignore
}

#Assign distribution group based on gender *************************************
$Male = "m", "M"
$Female = "f", "F"
$DName = Get-ADUser -Identity "$Username" | Select-Object -ExpandProperty DistinguishedName
$LDAPUser = [ADSI]"LDAP://$DName"
Function Assign-Group {
    if ($Male.contains($Gender) -eq $True){
        $MenMember = $MenGroup.IsMember($LDAPUser.ADsPath)
        if ($MenMember -eq $False){
            Add-ADGroupMember -Identity "Men" -Members $Username -ErrorVariable $Err1 -ErrorAction "SilentlyContinue" -Confirm:$false
            Write-Host "Added $Username to distribution group for Men"
        }
        else {
            Write-Host "$Username is already a member of distribution group for Men"
        }
    }
    elseif ($Female.contains($Gender) -eq $True){
        $WomenMember = $WomenGroup.IsMember($LDAPUser.ADsPath)
        if ($WomenMember -eq $False){
            Add-ADGroupMember -Identity "Women" -Members $Username -ErrorVariable $Err2 -ErrorAction "SilentlyContinue" -Confirm:$false
            Write-Host "Added $Username to distribution group for Women"
        }
        else {
            Write-Host "$Username is already a member of distribution group for Women"
        }     
    }
    else {
        Write-Host "Something with the gender variable went wrong..."
    }
Assign-Group
}

#Move user to applicable OU **************************************************
Move-ADObject -Identity (Get-ADuser $Username).objectGUID -Server $Server -TargetPath "OU=$Department,OU=User OU,DC=domain,Dc=local"

#Declare additional variables ************************************************
$Status = (Get-ADUser -Identity $Username -Server $Server).Enabled
$UserGroups = Get-ADPrincipalGroupMembership $Username | Select Name
$UserOU = Get-ADUser -Identity $Username -Server $Server | select @{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}

#Create user's home drive and set permissions ********************************
New-Item -ItemType directory -Path "$HomePath\$Username" | Out-Null 
# You must create a template folder with the default permissions you want at this location $HomePath\template-DoNotDeleteOrMove"
$ACLp = (Get-Item "$HomePath\template-DoNotDeleteOrMove").GetAccessControl('Access')
$ARpe = New-Object System.Security.AccessControl.FileSystemAccessRule("$Username","Modify","ContainerInherit,ObjectInherit","None","Allow") 
$ACLp.AddAccessRule($ARpe)                                
Set-ACL -Path "$HomePath\$Username" -ACLObject $ACLp
$HomeDrive = "$HomePath\$Username"

# Optional: Create user's application dirve, grant user Modify permissions
New-Item -ItemType directory -Path "$AppPath\$Username" | Out-Null 
$ACLn = (Get-Item "$AppPath\template-DoNotDelete").GetAccessControl('Access')
$ARn = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$ACLn.SetAccessRule($ARn)
Set-Acl -path $AppPath\$Username -AclObject $ACLn
$AppDrive = "$AppPath\$Username"

#Create Department Specific Folder ********************************************
Function Create-DeptFolder {

    if ($Department -eq "Executives"){
        
        #Create audit folder for users in the Executive department
        $Reports = "\\AuditFolderPath\Audits"
        New-Item -ItemType Directory -Path "$Reports\$Username" | Out-Null

        #Open Properties of user's new Call Audits Folder to add Access Rule for user
        $Object = new-object -com Shell.Application
        $CallFolder = $Object.NameSpace("$Reports\$Username")
        $CallFolder.Self.InvokeVerb("Properties")

        #Place shortcut to user's report folder in Home Drive
        #Create a shortcut
        $Wshell = New-Object -ComObject WScript.Shell
        $lnk = $Wshell.CreateShortcut($HomeDrive+"\Reports.lnk")
        $lnk.TargetPath = "$Reports\$Username"
        $lnk.Save()
    }
}
Create-DeptFolder

#Verify account enabled. Required step so that mailbox creation succeeds.*****
Function Get-Status{
     if ($Status -eq $False){
        Write-Host "$Username was not enabled. Enabling..."
        Set-ADUser -Identity $Username -Server $Server -Enabled $True
    }
}
Get-Status

#Determine Exchange storage group with most free space ************************
$UserCan = (Get-ADUser -Identity $Username -Server $Server -Property CanonicalName).CanonicalName
$edbGUID = (Get-MailboxDatabase -server $Exchange | Sort-Object length | Select -First 1).guid
$UserGUID = (Get-ADUser -Identity $Username -Server $Server).ObjectGUID
$UserDN = (Get-ADUser -Identity $Username -Server $Server).distinguishedname

#Create mailbox ***************************************************************
Enable-Mailbox -DomainController $Server -Identity "$UserCan" -Alias "$Username" -Database "$edbGUID" -ManagedFolderMailboxPolicy "Mailbox Cleanup"

# Write logs to log file ******************************************************
#Append text file to confirming actions taken
$UserGroups = (Get-ADPrincipalGroupMembership $Username).name
Add-Content "\\ ScriptLogPath \$username.txt" "Create User: $Fullname"
Add-Content "\\ScriptLogPath\$username.txt" " "
Add-Content “\\ScriptLogPath\$username.txt” "DateTime: $DTStamp"
Add-Content “\\ScriptLogPath\$username.txt” "Account Enabled: $Status"
Add-Content “\\ScriptLogPath\$username.txt” "Email: $Email"
#$MailStatus = Get-Mailbox $Username
Add-Content “\\ScriptLogPath\$username.txt” "Mailbox Created: $MailStatus"
Add-Content “\\ScriptLogPath\$username.txt” "Department: $Department"
Add-Content “\\ScriptLogPath\$username.txt” "Copied from: $Peer"
Add-Content “\\ScriptLogPath\$username.txt” "Group Membership: $UserGroups"
Add-Content “\\ScriptLogPath\$username.txt” "ADUC Location: $UserCan"
Add-Content “\\ScriptLogPath\$username.txt” "ipPhone: $ipPhone"
Add-Content “\\ScriptLogPath\$username.txt” "$Username P Drive created at $HomePath\$Username"
Add-Content “\\ScriptLogPath\$username.txt” "$Username N Drive created at $AppPath\$Username"
Add-Content “\\ScriptLogPath\$username.txt” "Errors:"
Add-Content “\\ScriptLogPath\$username.txt” "$Err1"
Add-Content “\\ScriptLogPath\$username.txt” "$Err2"
Add-Content “\\ScriptLogPath\$username.txt” "$Err3"
Add-Content “\\ScriptLogPath\$username.txt” "$Err4"
Add-Content “\\ScriptLogPath\$username.txt” "__________________________________________________________________________________"
# Open log file for viewing at script completion *****************************
& “\\ScriptLogPath\$username.txt”

Write-Host " "
Write-Host "##############################################"
Write-Host "#                                            #"
Write-Host "#                 User Created!              #"
Write-Host "#                                            #"
Write-Host "##############################################"
Write-Host " "
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
