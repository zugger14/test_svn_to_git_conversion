DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_eBaseMeterDataImport')

INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
	SELECT 'PRJ_eBaseMeterDataImport', '\ebase\packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
		UNION ALL 
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\eBase\Input\', '\Package.Variables[User::PS_DataFilePath].Properties[Value]', 'String'      
		UNION ALL
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\eBase\Output\Processed', '\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfsp1.essenttrading.nl\funcprod$\Trmtracker\eBase\Output\Error', '\Package.Variables[User::PS_ErrorFilePath].Properties[Value]', 'String'
	
--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'	