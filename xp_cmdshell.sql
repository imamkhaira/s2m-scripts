-- BEGIN SCRIPT TO ENABLE xp_cmdshell

-- this turns on advanced options and is needed to configure xp_cmdshell
sp_configure 'show advanced options', '1'
RECONFIGURE
-- this enables xp_cmdshell
sp_configure 'xp_cmdshell', '1' 
RECONFIGURE

-- END SCRIPT TO ENABLE xp_cmdshell


-- BEGIN SCRIPT TO DISABLE xp_cmdshell

-- this turns on advanced options and is needed to configure xp_cmdshell
sp_configure 'show advanced options', '1'
RECONFIGURE
-- this disables xp_cmdshell
sp_configure 'xp_cmdshell', '0' 
RECONFIGURE

-- END SCRIPT TO DISABLE xp_cmdshell