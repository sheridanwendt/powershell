This is a reference page for my ongoing [powershell repository](https://github.com/sheridanwendt/powershell) where I keep original powershell scripts that I have found useful in my IT career. Feel free to use or improve them. 


Not looking for Powershell? [Here are my other repositories.](https://github.com/sheridanwendt)

```markdown
# Happy Scripting!
```
### New User
[NewUser.ps1](https://github.com/sheridanwendt/powershell/blob/master/NewUser.ps1)
This script performs the normal steps involved in creating a new user, including: copying user in active directory, assigning group membership, creating a home drive folder, setting permissions, creating an application folder, setting permissions creating a folder based on the department the user is in, settings permissions, assigning gender in active directory, assigning group(s) based on gender in active directory, assigning a manager, assigning a state, assiging a phone extension in active directory, puting the user in the correct OU in active directory, creating an exchange mailbox using the storage group with the most free space, handle errors and log the actions taken

### Home Drive Cleanup
[HomeDriveCleanup.ps1](https://github.com/sheridanwendt/powershell/blob/master/HomeDriveCleanup.ps1)
This script queries Active Directory for a list of disabled user then checks a root folder, $HomeRoot, such as a directory containing user folders and if there is a folder name that matches a user in the disabled list it gets archived. The process is repeated if there is a directory defined for the $AppRoot variable. If a folder gets archived an entry is added to a log.

### Check Exchange Logs Space
[CheckExchangeLogsSpace.ps1](https://github.com/sheridanwendt/powershell/blob/master/CheckExchangeLogsSpace.ps1)
This script will retrieve the amount of free space remaining on any disk, specified by letter, on any computer or server, specified by it's name. Then an email will be sent to the address specified including the space details. 

### Check For VM Snapshots
[CheckForVMSnapshots.ps1](https://github.com/sheridanwendt/powershell/blob/master/CheckForVMSnapshots.ps1)
This script queries vCenter to determine if any VM snapshots exist and sends an email if any snapshots are found. Prevents empty storage arry level snapshots from being empty and unusable due to taking snapshots of the latest VM level snapshot.

### Fix Permissions
[FixPermissions.ps1](https://github.com/sheridanwendt/powershell/blob/master/FixPermissions.ps1)
This script will copy the permissions of a template folder ($Template) then assign those permissions to a list of folders inside of a root folder. It will also add an access rule ($AR) to the copied permissions, which is useful to grant "Modify" access to the folder for a user that has the same name as the $SubFolder.name (works only when the folder name is the same as the username, such as a Home Drive.)


[Home](http://SheridanWendt.com) [Music](http://music.SheridanWendt.com) [Projects](http://projects.SheridanWendt.com)
