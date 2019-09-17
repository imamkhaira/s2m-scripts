##
 # SharePoint Server Database IP change tool
 #
 # @author: Imam Khaira (EPCR 053)
 # @param {string} newServerAddres The new IP address or FQDN of the SQL Server
##

# get the new server address parameter
param(
	[string]$NewServerAddress = $false
);

# loads SharePoint powershell module
Add-PSSnapin Microsoft.SharePoint.Powershell;
Write-Host 'Loaded SharePoint Module';

# exit if the server address is not supplied
if ($NewServerAddress -eq $false) {
    Write-Host 'You need to supply the new server address';
    Exit 1;

} else {
    # get list of SharePoint databases
    $contDBs = Get-SPDatabase;

    # change the database server address for each content database
    ForEach($contDB in $contDBs){
        Write-Host "Changing -$($contDB.Name)- address from -$($contDB.Server) to $($NewServerAddress)-";
        $contDB.ChangeDatabaseInstance($NewServerAddress);
    
    }
    Write-Host 'Database server change successfull';
}
