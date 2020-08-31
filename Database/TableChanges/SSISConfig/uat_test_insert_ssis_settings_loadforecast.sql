
-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PRJ_LoadForecastDataImportIS', 'PKG_LoadForecastNominatorRequest', 'PKG_LoadForecastDataParse', 'PKG_LoadForecastDataImport')

-- apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PRJ_LoadForecastDataImportIS',	'deal_detail_hour',	'\Package.Variables[User::PS_PartitionedTableName].Properties[Values]',	'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\LoadForecast\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]',	'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'1', '\Package.Variables[User::PS_ImportType].Properties[Value]', 'Int16'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfsa01.et.local\funcacce$\trmtracker\TEST\LoadForecast\NominatorResponseData\', '\Package.Variables[User::PS_HourlyDataSourceFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfsa01.et.local\funcacce$\trmtracker\TEST\LoadForecast\NominatorOutput\Processed\', '\Package.Variables[User::PS_HourlyDataProcessedFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'Data_', '\Package.Variables[User::PS_HourlyDataPartitionFolderPrefix].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'@[User::PS_HourlyDataFolderLocation] + @[User::PS_HourlyDataPartitionFolderPrefix] + @[User::PS_PartitionIDString] + "\\" + @[User::PS_HourlyDataSplitSourceFileName]', '\Package.Variables[User::PS_HourlyDataFullFileName].Properties[Expression]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'D:\Application\TRMTracker\SSISPackage_TEST\LoadForecast\DealDetailHourData\', '\Package.Variables[User::PS_HourlyDataFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfsa01.et.local\funcacce$\trmtracker\TEST\LoadForecast\NominatorOutput\Error\', '\Package.Variables[User::PS_HourlyDataErrorFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'LoadForecastHandleErroroneousFiles.dtsx', '\Package.Variables[User::PS_ErrorHandlerPackageName].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'.csv',	'\Package.Variables[User::PS_CSVFileExtension].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_LoadForecastDataParse', '2', '\Package.Variables[User::PS_ImportFileTypeLRS].Properties[Value]', 'Int32'
UNION ALL
SELECT 'PKG_LoadForecastDataParse', '1', '\Package.Variables[User::PS_ImportFileTypeCSV].Properties[Value]', 'Int32'
UNION ALL
SELECT 'PKG_LoadForecastDataParse',	'.txt',	'\Package.Variables[User::PS_CSVProcessedFileExtension].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_LoadForecastDataImport', 'stage_deal_detail_hour_',	'\Package.Variables[User::PS_StagingTableNamePrefix].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_LoadForecastDataImport', '150',	'\Package.Variables[User::PS_PartitionCount].Properties[Value]', 'Int16'
UNION ALL
SELECT 'PKG_LoadForecastNominatorRequest', '\\emgfsa01.et.local\funcacce$\trmtracker\TEST\LoadForecast\NominatorRequestData\gas', '\Package.Variables[User::PS_RequestFolderPathGas].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_LoadForecastNominatorRequest', '\\emgfsa01.et.local\funcacce$\trmtracker\TEST\LoadForecast\NominatorRequestData\power', '\Package.Variables[User::PS_RequestFolderPathPower].Properties[Value]', 'String'
UNION ALL
SELECT  'PKG_LoadForecastNominatorRequest', '\LoadForecast\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage_TEST\'