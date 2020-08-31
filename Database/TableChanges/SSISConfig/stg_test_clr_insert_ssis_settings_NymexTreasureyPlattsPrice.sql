-- clear existing settings
DELETE FROM   [ssis_configurations] WHERE  ConfigurationFilter IN ('PKG_NymexTreasuryPlattsPriceCurveImport')

-- apply new settings
INSERT INTO [ssis_configurations](ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', '\NymexTreasuryPlattsPriceCurve\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', '21', '\Package.Connections[Platts FTP].Properties[ServerPort]', 'Int16'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'D:\FARRMS_DataSrc\TRMTracker_TEST\NymexTreasuryPlattsPriceCurve\Data', '\Package.Variables[User::ps_workspace].Properties[Value]', 'String'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'ftp.platts.com', '\Package.Connections[Platts FTP].Properties[ServerName]', 'String'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'ftp59663', '\Package.Connections[Platts FTP].Properties[ServerPassword]', 'String'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'jocelyn_mariano', '\Package.Connections[Platts FTP].Properties[ServerUserName]', 'String'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'TRUE', '\Package.Connections[Platts FTP].Properties[UsePassiveMode]', 'Boolean'
UNION
SELECT 'PKG_NymexTreasuryPlattsPriceCurveImport', 'y', '\Package.Variables[User::ps_param_sendMail].Properties[Value]', 'String'


UPDATE connection_string SET import_path = 'D:\FARRMS_SPTFiles\SSIS\TRMTracker_TEST'
