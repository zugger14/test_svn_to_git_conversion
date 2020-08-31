DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_shortTermForecastImport')

INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
	SELECT 'PRJ_shortTermForecastImport', '\ShortTermForecast\Packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
		UNION ALL 
	SELECT 'PRJ_shortTermForecastImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\ShortTermForecast\Input\', '\Package.Variables[User::PS_DataFilePath].Properties[Value]', 'String'      
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\ShortTermForecast\Output\Processed\', '\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\ShortTermForecast\Output\Error\', '\Package.Variables[User::PS_ErrorFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', 'Gas', '\Package.Variables[User::PS_FolderNameGas].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', 'Power', '\Package.Variables[User::PS_FolderNamePower].Properties[Value]', 'String'


--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'			