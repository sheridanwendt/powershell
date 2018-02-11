This is a reference page for my ongoing [powershell repository](https://github.com/sheridanwendt/powershell) where I keep original powershell scripts that I have found useful in my IT career. Feel free to use or improve them. 


Not looking for Powershell? [Here are my other repositories.](https://github.com/sheridanwendt)

```markdown
# Happy Scripting!
```
## Active Directory User Management

### New User
[NewUser.ps1](https://github.com/sheridanwendt/powershell/blob/master/NewUser.ps1)
This script performs the normal steps involved in creating a new user, including: copying user in active directory, assigning group membership, creating a home drive folder, setting permissions, creating an application folder, setting permissions creating a folder based on the department the user is in, settings permissions, assigning gender in active directory, assigning group(s) based on gender in active directory, assigning a manager, assigning a state, assiging a phone extension in active directory, puting the user in the correct OU in active directory, creating an exchange mailbox using the storage group with the most free space, handle errors and log the actions taken

### Terminate User
[TerminateUser.ps1](https://github.com/sheridanwendt/powershell/blob/master/TerminateUser.ps1)
This script performs the normal steps involved in terminating access for a specific user, including: disabling in ADUC, setting a random password, exporting a list of group membership for later reference, removing user from all groups for security reasons, archiving user folders, forwarding future emails to the user's previous supervisor, disabling ActiveSync, removing user's ipPhone entry for allocation to Cisco devices, and move the user's Active Director user object to an OU named Disabled so ADUC stays nice and clean.
Note: Able to skips "Protected Users" such as; CEOuser, COOuser, CIOuser, CISOuser, etc.

## File Sharing, Cleanup, and Manipulation

### Home Drive Cleanup
[HomeDriveCleanup.ps1](https://github.com/sheridanwendt/powershell/blob/master/HomeDriveCleanup.ps1)
This script queries Active Directory for a list of disabled user then checks a root folder, $HomeRoot, such as a directory containing user folders and if there is a folder name that matches a user in the disabled list it gets archived. The process is repeated if there is a directory defined for the $AppRoot variable. If a folder gets archived an entry is added to a log.

### Check Exchange Logs Space
[CheckExchangeLogsSpace.ps1](https://github.com/sheridanwendt/powershell/blob/master/CheckExchangeLogsSpace.ps1)
This script will retrieve the amount of free space remaining on any disk, specified by letter, on any computer or server, specified by it's name. Then an email will be sent to the address specified including the space details. 

### Fix Permissions
[FixPermissions.ps1](https://github.com/sheridanwendt/powershell/blob/master/FixPermissions.ps1)
This script will copy the permissions of a template folder ($Template) then assign those permissions to a list of folders inside of a root folder. It will also add an access rule ($AR) to the copied permissions, which is useful to grant "Modify" access to the folder for a user that has the same name as the $SubFolder.name (works only when the folder name is the same as the username, such as a Home Drive.)

## Custom Notifications 

### SMS Notifications
[SMSNotifications.ps1](https://github.com/sheridanwendt/powershell/blob/master/SMSNotifications.ps1)
Description: This script assigns a various list of customizable messages to the variable $Messages, generates a random email address (so these notifications cannot be blocked by the recipient), and sends the message via email to a phone carrier's email:sms gateway. A 30 second break is taken and then the next text is sent until 10 (number assigned to $MaxCount) notifications have been sent.
Resource: https://en.wikipedia.org/wiki/SMS_gateway#Spreadsheet-to-SMS_gateway

## VMWare Related Scripts

### Check For VM Snapshots
[CheckForVMSnapshots.ps1](https://github.com/sheridanwendt/powershell/blob/master/CheckForVMSnapshots.ps1)
This script queries vCenter to determine if any VM snapshots exist and sends an email if any snapshots are found. Prevents empty storage arry level snapshots from being empty and unusable due to taking snapshots of the latest VM level snapshot.

### VMWare: Rescan All Storage (new HBAs and new VMFS)
This script will instruct each host in the cluster to rescan it's storage adapters for new physical (HBAs) storage devices AND for VMFS volumes on LUNs
https://github.com/sheridanwendt/powershell/blob/master/VMWare_RescanStorage.ps1

### VMWare: Rescan for new HBAs
[VMWare_RescanHBAs.ps1](https://github.com/sheridanwendt/powershell/blob/master/VMWare_RescanHBAs.ps1)
This script will instruct each host in a cluster to rescan it's Host Bus Adapters (HBAs) for new storage devices

### VMWare: Rescan existing HBAs for new VMFS volumes
[VMWare_RescanVMFS.ps1](https://github.com/sheridanwendt/powershell/blob/master/VMWare_RescanVMFS.ps1)
This script will instruct each host in the cluster to rescan it's existing Host Bus Adapters (HBAs) for new VMFS volumes



[Home](http://SheridanWendt.com) [Music](http://music.SheridanWendt.com) [Projects](http://projects.SheridanWendt.com)
