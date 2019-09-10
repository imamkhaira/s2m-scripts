# s2m-scripts
Painless and automatic SharePoint backup and restore script

# PREREQUISITE
0. create a shared folder in your NAS or workstation that is accessible from the SharePoint WFE via SMB.
1. log in to SharePoint Server's Web Front-end machine as Farm Admininistrator user using remote dekstop, PowerShell Remote or local terminal. 
2. copy ALL files in this script bundle and place is somewhere convenient. in this example, lets put in on the desktop.

# BACK UP
1. to backup, edit the $backupdir variable in backup.ps1 to your own backup location. then run the script by typing ./backup.ps1

# RESTORE
1. to restore, edit the $backupdir variable in restore.ps1 to your own backup location. then run the script by typing ./backup.ps1

# credits
contains work derived from Ingo Karstein's PowerShell to .exe conversion script.
all credits reserved to him.

