-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_PriceCurveVolatilityCorrelationDataImport')

-- apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'PriceCurve_Volatility_Correlation\Package\', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'True',	'\Package.Variables[User::PS_MailServerUseSsl].Properties[Value]', 'Boolean'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'import@pioneersolutionsglobal.com','\Package.Variables[User::PS_MailServerUsername].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', '995', '\Package.Variables[User::PS_MailServerPort].Properties[Value]', 'Int32'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', '21Feb2013', '\Package.Variables[User::PS_MailServerPassword].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'pod51009.outlook.com', '\Package.Variables[User::PS_MailServerHostName].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'crc.nv.gov,pioneersolutionsglobal.com,silverstateenergy.org', '\Package.Variables[User::PS_EmailFromAddressDomain].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\VolatilityData\', '\Package.Variables[User::PS_DownLoadedMailDestinationFolderForVolatility].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\PriceData\', '\Package.Variables[User::PS_DownLoadedMailDestinationFolderForPrice].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\CorrelationData\', '\Package.Variables[User::PS_DownLoadedMailDestinationFolderForCorrelation].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\VolatilityData', '\Package.Variables[User::PS_DataSourceFolderVolatility].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\PriceData', '\Package.Variables[User::PS_DataSourceFolderPrice].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\CorrelationData', '\Package.Variables[User::PS_DataSourceFolderCorrelation].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Data\', '\Package.Variables[User::PS_DataSourceFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Processed\', '\Package.Variables[User::PS_DataProcessedFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'D:\SNWA_SSIS\PriceCurve_Volatility_Correlation\Error\', '\Package.Variables[User::PS_DataErrorFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_PriceCurveVolatilityCorrelationDataImport', 'SNWA', '\Package.Variables[User::PS_EmailSubject].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\SNWA_SSIS\',sql_proxy_account = 'TRMTracker_Proxy',db_Servername = 'Essent'


--SELECT  * FROM  ssis_configurations

--update ssis_configurations set ConfiguredValue = 'ssingh@pioneersolutionsglobal.com' where PackagePath = '\Package.Variables[User::PS_MailServerUsername].Properties[Value]'
--update ssis_configurations set ConfiguredValue = 'pnr@sam21' where PackagePath = '\Package.Variables[User::PS_MailServerPassword].Properties[Value]'
--update ssis_configurations set ConfiguredValue = 'pioneersolutionsglobal.com,gmail.com' where PackagePath = '\Package.Variables[User::PS_EmailFromAddressDomain].Properties[Value]'