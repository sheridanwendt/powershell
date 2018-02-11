# ********************************************************************************
#
# Script Name: FixPermissions.ps1
# Version: 1.0
# Author: Sheridan Wendt
# Date: 9/26/2017
# Applies to: User Folders
#
# Description: This script will copy the permissions of a template folder 
# ($Template) then assign those permissions to a list of folders inside of a root 
# folder. It will also add an access rule ($AR) to the copied permissions, which 
# is useful to grant "Modify" access to the folder for a user that has the same 
# name as the $SubFolder.name (works only when the folder name is the same as the 
# username, such as a Home Drive.)
#
# ********************************************************************************

$Greeting = @"
########################################################################
#                                                                      #
#                  Welcome to the Fix Permissions Script!              #
#                  --------------------------------------              #
#                                                                      #
# Description: This script will copy the permissions of a template     #
# folder ($Template) then assign those permissions to a list of        #
# folders inside of a root folder. It will also add an access rule     #
# ($AR) to the copied permissions, which is useful to grant "Modify"   #
# access to the folder for a user that has the same                    #
# name as the $SubFolder.name (works only when the folder name is the  #
# same as the username, such as a Home Drive.)                         #
#                                                                      #
########################################################################

Insert address for Template folder with no backslash on the end.
Example: \\FileServer\F$\Template

"@
$Greeting
Function Set-Permissions{
$Template = Read-Host "Template Address"
$TemplateACL = Get-Item "$Template"
$RootFolder = Read-Host "Root Folder"
$RootDirectory = Get-ChildItem "$RootFolder" -Directory
    foreach ($SubFolder in $RootDirectory) {
    $Path = $SubFolder.FullName
    $ACL = ($TemplateACL).GetAccessControl('Access')
    $Username = $SubFolder.Name
    $AR = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $ACL.AddAccessRule($AR)
    Set-Acl -path $Path -ACLObject $ACL
    }
}
Set-Permissions

Write-Host "Done"