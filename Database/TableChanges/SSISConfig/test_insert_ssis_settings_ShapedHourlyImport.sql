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