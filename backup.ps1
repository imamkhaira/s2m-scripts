<# 
    @Title: S2M-Backup.ps1
    @Purpose: automatically create a SharePoint Site backup
    @Author: Imam Miftahul Khaira (EPCR 053)
    @Date: 13 December 2018

    this code consists of 2 parts. 
    - first part is getting this script an Admin privileges,
    - second part is running the backup itself.
    
    !!! IMPORTANT !!!
    please change the variables commented in CAPITAL LETTERS into your needs.
    this script backups S2M websites directly to \\BACKUP-SERVER\server-backup\sharepoint\spbackup
    defined in the $backupdir variable
#>

# -- PART 1--
# we need to elevate current script to Administrator without need to click 'run as admin'
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
# IF we are running "as Administrator" then change the title to Elevated
if ($myWindowsPrincipal.IsInRole($adminRole)){ 
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   Clear-Host
   }
else {
   # ELSE, we are not running "as Administrator". 
   # so need to relaunch this shell as administrator
   
   # first, Create a process that starts new PowerShell
   $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process!
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit AND KILL the current unelevated process
   exit
   }
 

# -- PART 2 --
# take the newly spawned admin shell after kill the old one
$ver = $host | Select version
if ($ver.Version.Major -gt 1)  {$Host.Runspace.ThreadOptions = "ReuseThread"}

# load the SharePoint command module and return to home directory
Add-PsSnapin Microsoft.SharePoint.PowerShell
Set-Location $home

# BACKUP!
# first, ge get the current time this script is executed. 
# then set the backup location to BACKUP-SERVER. 

$timestamp = $(Get-Date -f ddMMyyyy)

# list down the subdomain (Web Application) we wanna backup in the $subdomains array.
# example, if the site to be backed up is https://epehr.s2m.online, then add epehr into this array.
# CHANGE THE VARIABLE BELOW To AN APPROPRIATE SITE SUBDOMAIN.
$subdomains = "epesb", "epehr"

# create a directory to store the backup files using the Timestamp.
# then switch to that directory
New-Item -Path $backupdir -ItemType directory

# CHANGE TTHE VARIABLE BELOW To AN APPROPRIATE BACKUP LOCATION.
$backupdir = "\\BACKUP-SERVER\server-backup\sharepoint\spbackup\$timestamp\"

# for every subdomain in the above array, perform backup of all its sites.
# first, we need to convert it into a full URL of the subdomain (web app)..
# then, we get the list of all sites in that subdomain
ForEach ($subdomain in $subdomains) {
    
    # CHANGE THE VARIABLE BELOW To AN APPROPRIATE SITE ROOT URL.
    $fullURL = "https://$subdomain.sitename.tld/sites/*"
    $sites = Get-SPSite -Identity $fullURL -Limit ALL

    # for every single site found, perform the backup and 
    # put the timestamp in the file name.
    ForEach ($site in $sites){
        $filename = "$subdomain-$($site.Url.toString().Remove(0,(26+$subdomain.Length)))"
        Write-Output "Backing up $($site.Url.ToString()) ==TO== $filename.bak ..."
        Backup-SPSite $site.Url.ToString() -Path "$backupdir$filename.bak" -UseSQLSnapshot
        Write-Output "OK"
    }
    Write-Output "Done."
    # repeat.
}

# measures the time it takes to run this script. good indication of system performance
$elapsedTime = $(get-date) - $script:StartTime
Write-Output "Backup to $backupdir has been finished"
Write-Output "Total time taken: $elapsedTime"
