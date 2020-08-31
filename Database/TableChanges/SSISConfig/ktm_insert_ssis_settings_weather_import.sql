
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_Weather')

INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)	
	SELECT 'PRJ_Weather', '\\db01\FARRMS_DataSrc\TRMTracker_New_Framework\Weather\download', '\Package.Variables[User::PS_LocalPath].Properties[Value]', 'String'
		UNION ALL 
	SELECT 'PRJ_Weather', '\\db01\FARRMS_DataSrc\TRMTracker_New_Framework\Weather\Processed', '\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_Weather', '\\db01\FARRMS_DataSrc\TRMTracker_New_Framework\Weather\Error', '\Package.Variables[User::PS_ErrorFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_Weather', '\weather\Package',	'\Package.Variables[User::PS_PackageSubDir].Properties[Value]',	'String'
		UNION ALL
	SELECT 'PRJ_Weather',	'gasday',	'\Package.Connections[WeatherBank FTP].Properties[ServerUserName]',	'String'
		UNION ALL
	SELECT 'PRJ_Weather',	'21',	'\Package.Connections[WeatherBank FTP].Properties[ServerPort]',	'Int16'
		UNION ALL
	SELECT 'PRJ_Weather',	'qgd8t8',	'\Package.Connections[WeatherBank FTP].Properties[ServerPassword]',	'String'
		UNION ALL
	SELECT 'PRJ_Weather',	'FTP.weatherbank.com',	'\Package.Connections[WeatherBank FTP].Properties[ServerName]',	'String'
		UNION ALL
	SELECT 'PRJ_Weather',	'True',	'\Package.Connections[WeatherBank FTP].Properties[UsePassiveMode]',	'Boolean'
		UNION ALL
	SELECT 'PRJ_Weather', 'True',	'\Package.Variables[User::PS_EnableFtp].Properties[Value]',	'String'


--update import path
UPDATE connection_string SET import_path = 'D:\FARRMS_SPTFiles\SSIS\TRMTracker_New_Framework'
	

