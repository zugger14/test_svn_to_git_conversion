DELETE FROM ssis_configurations where configurationFilter = 'PKG_NymexTreasuryPlattsPriceCurveImport' 
INSERT INTO ssis_configurations(ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
SELECT 'PKG_PlattsPriceCurveImport','C:\Program Files (x86)\WinSCP\WinSCP.exe','\Package.Variables[User::PS_winscp_path].Properties[Value]','String'

UNION ALL
SELECT 'PKG_PlattsPriceCurveImport','ssh-rsa 2048 sy9xqy25YcF8bs6l7Btrtwpqu65/5HE8b8+hrGhHJtI=','\Package.Variables[User::PS_SSH_KEY].Properties[Value]','String'
UNION ALL
SELECT 'PKG_PlattsPriceCurveImport','E:\FARRMS_DataSrc\TRMTracker_LADWP\NymexTreasuryPlattsPriceCurve\Data\PriceCurves\Temp\Files\','\Package.Variables[User::PS_LocalPath].Properties[Value]','String'
UNION ALL
SELECT 'PKG_PlattsPriceCurveImport','/today/*.*','\Package.Variables[User::PS_FTP_Path].Properties[Value]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','jocelyn_mariano','\Package.Connections[Platts FTP].Properties[PS_ServerUserName]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','21','\Package.Connections[Platts FTP].Properties[ServerPort]','Int16'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','ftp59663','\Package.Connections[Platts FTP].Properties[PS_ServerPassword]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','sftp.platts.com','\Package.Connections[Platts FTP].Properties[PS_ServerName]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','True','\Package.Connections[Platts FTP].Properties[UsePassiveMode]','Boolean'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','E:\FARRMS_DataSrc\TRMTracker_LADWP\NymexTreasuryPlattsPriceCurve\Data','\Package.Variables[User::ps_workspace].Properties[Value]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','y','\Package.Variables[User::ps_param_sendMail].Properties[Value]','String'
UNION ALL
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport','\NymexTreasuryPlattsPriceCurve\Package','\Package.Variables[User::PS_PackageSubDir].Properties[Value]','String'