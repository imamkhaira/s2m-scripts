<# 
    @Title: S2M-Restore.ps1
    @Purpose: To prevent human error in site restore
    @Author: Imam Miftahul Khaira (EPCR 053)
    @Date: 31 January 2019

    this code consists of 3 parts. 

    this script backups S2M websites before restore operation
    directly to C:\backup folder
    using "SPFARM" as the backup account.
#>

# get the parameters for the script. 
# this will be the same as the parameter of Restore-SPSite, just add -Target before site URL
param(
    [string]$Target = "nope",
    [string]$Path = "nope",
    [switch]$Force = $false,
    [string]$DatabaseServer = "nope",
    [string]$DatabaseName = "nope"
)

# Load SharePoint PowerShell Module, then clear the screen.
Add-PsSnapin Microsoft.SharePoint.PowerShell
Clear

# for safety, we backup the target before restoring it with anything.
# in case something goes terribly wrong, it can be restored again.
# this function executes the backup job after all requirements are satisfied
function Run-Backup{
    param($Target)
    $a = $($Target.ToString()) -match "https://(?<subdomain>.*).s2m.online/sites/(?<sitename>.*)"
    $backupdir= "C:\Users\SPFarm\Desktop\backup\"
    $filename = "$($matches['subdomain']).$($matches['sitename'])"
    Write-Output ">> RUNNING: Backup-SPSite $Target -Path $backupdir$filename.$(Get-Date -f ddMMyyyy).bak -UseSQLSnapshot"
    Backup-SPSite $Target -Path $backupdir$filename.$(Get-Date -f ddMMyyyy).bak -UseSQLSnapshot
    Write-Output ">> backup OK"
}

# the function to run the restore.
# it requires the user to explicitly type "PROCEED AND RESTORE" to run.
function Run-Restore{
    param($Target, $Path, $DatabaseServer, $DatabaseName)
    $confirm = Read-Host -Prompt "PLEASE TYPE 'PROCEED AND RESTORE' to continue"
    if ($confirm -eq "PROCEED AND RESTORE") {
        Write-Output "Command accepted"
        Run-Backup $Target
        Start-Sleep -s 4
        Write-Output ">> RUNNING: Restore-SPSite $Target -Path $Path -Force -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName ..."
        Restore-SPSite $Target -Path $Path -Force -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName
        Start-Sleep -s 4
        Write-Output "Restore Complete."
    } else {
        Write-Output "Command not accepted"
        Exit
    }
}

# the function to start the script in interactive mode
# basically, it translates user input into a Run-Restore function arguments.
function Restore-Interactive {
    param ()
    $Target = Read-Host -Prompt "Enter the target site URL (ex: https://demo.s2m.online/sites/AOL)"
    $Path = Read-Host -Prompt "Enter path to .bak file"
    $DatabaseServer = Read-Host -Prompt "Enter IP address of database server"
    $DatabaseName = Read-Host -Prompt "enter the database name: (ex: WSS_Content_demo_s2m_online_AOL)"
    Run-Restore $Target $Path $DatabaseServer $DatabaseName
}

# if there is no parameter supplied, start in interactive mode
# get all the needed parameter by prompting in command line
# the parameter can be supplied as in a norman Restore-SPSite command.
Write-Output "....."
if ($Target -eq "nope") {
    Write-Output ">> S2M-Restore.ps1 interactive mode"
    Restore-Interactive
} elseif (($Path -eq "nope") -or ($DatabaseServer -eq "nope") -or ($DatabaseName -eq "nope")){
    Write-Output "parameter error, check again"
} else {
    Write-Output ">> S2M-Restore.ps1 non-interactive mode"
    Write-Output "PLEASE CONFIRM THE FOLLOWING CAREFULLY."
    Write-Output "Site to be restored: $Target"
    Write-Output "Restore file: $Path"
    Write-Output "Database server: $DatabaseServer"
    Write-Output "Database name: $DatabaseName"
    Run-Restore $Target $Path $DatabaseServer $DatabaseName
}

<# 
SAMPLE OF COMMAND. 
simply change 'Restore-SPSite' to 'S2M-Restore -Target'

example:
>> Restore-SPSite "https://demo.s2m.online/sites/test2" -Path "C:\Users\SPFarm\Desktop\backup\test2.bak" -Force -DatabaseServer "10.10.3.25" -DatabaseName "WSS_Content_demo_s2m_online_Timesheet"

to:
>> S2M-Restore -Target "https://demo.s2m.online/sites/test2" -Path "C:\Users\SPFarm\Desktop\backup\test2.bak" -Force -DatabaseServer "10.10.3.25" -DatabaseName "WSS_Content_demo_s2m_online_Timesheet"
#>
