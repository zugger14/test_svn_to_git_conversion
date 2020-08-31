-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_CMAInterface', 'PKG_CMAResponse', 'PKG_CMARequest')

-- apply new settings
INSERT ssis_configurations(ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
      SELECT 'PRJ_CMAInterface', 'SPM', '\Package.Variables[User::PS_RequestSystem].Properties[Value]', 'String'
			UNION ALL
      SELECT 'PRJ_CMAInterface', '\CMA\Packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
			UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\Application\TRMTracker\SSISPackage\CMA\xsd\source.xsd', '\Package.Variables[User::PS_XsdLocation].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '2', '\Package.Variables[User::PS_SourceSystemId].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\batch\Data\SPM', '\Package.Variables[User::PS_SourceFilePath].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\Application\TRMTracker\SSISPackage\CMA\xsd\response.xsd', '\Package.Variables[User::PS_ResponseXsdLocation].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\Batch\Response', '\Package.Variables[User::PS_ResponseFilePath].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\batch\Data\SPM\Archive', '\Package.Variables[User::PS_ProcessedFilePathSource].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\batch\Response\Archive', '\Package.Variables[User::PS_ProcessedFilePathResponse].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '0', '\Package.Variables[User::PS_IsDst].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\batch\Data\SPM\Faulty', '\Package.Variables[User::PS_ErrorFilePathSource].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_ValuationUnit].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Input\batch','\Package.Variables[User::PS_RequestXmlFolder].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', 'CMA', '\Package.Variables[User::PS_MarketValueId].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_KeyValue].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_Granularity].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '\\emgfst01.et.local\functest$\trmtracker\CMA\Data\Output\batch\Response\Faulty','\Package.Variables[User::PS_ErrorFilePathResponse].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '4500', '\Package.Variables[User::PS_CsValueId].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', '77', '\Package.Variables[User::PS_ActValueId].Properties[Value]', 'Int32'
      
--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'



DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_eBaseMeterDataImport')

INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
	SELECT 'PRJ_eBaseMeterDataImport', '\ebase\packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
		UNION ALL 
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfst01.et.local\functest$\trmtracker\eBase\Input', '\Package.Variables[User::PS_DataFilePath].Properties[Value]', 'String'      
		UNION ALL
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfst01.et.local\functest$\trmtracker\eBase\Output\Processed', '\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_eBaseMeterDataImport', '\\emgfst01.et.local\functest$\trmtracker\eBase\Output\Error', '\Package.Variables[User::PS_ErrorFilePath].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'	




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
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfst01.et.local\functest$\trmtracker\LoadForecast\NominatorResponseData\', '\Package.Variables[User::PS_HourlyDataSourceFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfst01.et.local\functest$\trmtracker\LoadForecast\NominatorOutput\Processed\', '\Package.Variables[User::PS_HourlyDataProcessedFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'Data_', '\Package.Variables[User::PS_HourlyDataPartitionFolderPrefix].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'@[User::PS_HourlyDataFolderLocation] + @[User::PS_HourlyDataPartitionFolderPrefix] + @[User::PS_PartitionIDString] + "\\" + @[User::PS_HourlyDataSplitSourceFileName]', '\Package.Variables[User::PS_HourlyDataFullFileName].Properties[Expression]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'D:\EssentSSIS\load_forecast\DealDetailHourData\', '\Package.Variables[User::PS_HourlyDataFolderLocation].Properties[Value]', 'String'
UNION ALL
SELECT 'PRJ_LoadForecastDataImportIS',	'\\emgfst01.et.local\functest$\trmtracker\LoadForecast\NominatorOutput\Error\', '\Package.Variables[User::PS_HourlyDataErrorFolderLocation].Properties[Value]', 'String'
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
SELECT 'PKG_LoadForecastNominatorRequest', '\\emgfst01.et.local\functest$\trmtracker\LoadForecast\NominatorRequestData\gas', '\Package.Variables[User::PS_RequestFolderPathGas].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_LoadForecastNominatorRequest', '\\emgfst01.et.local\functest$\trmtracker\LoadForecast\NominatorRequestData\power', '\Package.Variables[User::PS_RequestFolderPathPower].Properties[Value]', 'String'
UNION ALL
SELECT  'PKG_LoadForecastNominatorRequest', '\LoadForecast\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'



-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_RDBInterface')

-- apply new settings
INSERT ssis_configurations(ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
      SELECT 'PRJ_RDBInterface', '\RDB', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
      UNION ALL
	  SELECT 'PRJ_RDBInterface', 'D:\Temp\RDB_Output', '\Package.Variables[User::OutputPATH].Properties[Value]', 'String'
	  UNION ALL 
      SELECT 'PRJ_RDBInterface','D:\Temp\RDB_Output - Copy', '\Package.Variables[User::Copy_OutputPATH].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'



-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_ShapedHourlyDealImport')

-- apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PKG_ShapedHourlyDealImport', '\Shaped Hourly\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ShapedHourlyDealImport', 'ShapedHourlyDealErrorHandler.dtsx', '\Package.Variables[User::PS_ErrorHandlerPackageName].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ShapedHourlyDealImport', '\\emgfst01.et.local\functest$\trmtracker\Shaped Hourly\Data\Shaped Hourly Import Data\', '\Package.Variables[User::PS_DataSourceFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ShapedHourlyDealImport', '\\emgfst01.et.local\functest$\trmtracker\Shaped Hourly\Data\Processed\', '\Package.Variables[User::PS_DataProcessedFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ShapedHourlyDealImport', '\\emgfst01.et.local\functest$\trmtracker\Shaped Hourly\Data\Error\', '\Package.Variables[User::PS_DataErrorFolder].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'



DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_shortTermForecastImport')

INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
	SELECT 'PRJ_shortTermForecastImport', '\short_term_forecast\Packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
		UNION ALL 
	SELECT 'PRJ_shortTermForecastImport', '\\emgfst01.et.local\functest$\trmtracker\ShortTermForecast\Input\', '\Package.Variables[User::PS_DataFilePath].Properties[Value]', 'String'      
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', '\\emgfst01.et.local\functest$\trmtracker\ShortTermForecast\Output\Processed\', '\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', '\\emgfst01.et.local\functest$\trmtracker\ShortTermForecast\Output\Error\', '\Package.Variables[User::PS_ErrorFilePath].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', 'Gas', '\Package.Variables[User::PS_FolderNameGas].Properties[Value]', 'String'
		UNION ALL
	SELECT 'PRJ_shortTermForecastImport', 'Power', '\Package.Variables[User::PS_FolderNamePower].Properties[Value]', 'String'
			
--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'




-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_Trayport')

-- apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PKG_Trayport',	'D:\Application\TRMTracker\SSISPackage\Trayport\Trayport_Format.xsd',	'\Package.Variables[User::PS_XSDFormat].Properties[Value]',	'String'
UNION ALL
SELECT 'PKG_Trayport',	'\\emgfst01.et.local\functest$\trmtracker\Trayport\TrayportXMLDataOutput\Processed', '\Package.Variables[User::PS_XMLSucessFolder].Properties[Value]',	'String'
UNION ALL
SELECT 'PKG_Trayport',	'\\emgfst01.et.local\functest$\trmtracker\Trayport\TrayportXMLData', '\Package.Variables[User::PS_XMLInputFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_Trayport',	'\\emgfst01.et.local\functest$\trmtracker\Trayport\TrayportXMLDataOutput\Error', '\Package.Variables[User::PS_XML_ErrorFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_Trayport',	'\Trayport', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\Application\TRMTracker\SSISPackage\'



