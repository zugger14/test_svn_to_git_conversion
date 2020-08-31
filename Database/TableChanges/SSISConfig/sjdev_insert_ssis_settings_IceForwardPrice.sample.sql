
-- clear existing settings
DELETE FROM   [ssis_configurations] WHERE  ConfigurationFilter IN ('PKG_IcePriceCurveImport')

-- apply new settings
INSERT INTO [ssis_configurations](ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
SELECT 'PKG_IcePriceCurveImport', '\IceForwardPrice\Package\', '\Package.Variables[User::PS_packageSubDir].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'https://downloads.theice.com/Settlement_Reports/', '\Package.Variables[User::PS_priceUrl].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'd:\FARRMS_DataSrc\TRMTracker_Trunk_CLR\IceForwardPrice\download\', '\Package.Variables[User::PS_DownloadFolder].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'd:\FARRMS_DataSrc\TRMTracker_Trunk_CLR\IceForwardPrice\processed\', '\Package.Variables[User::PS_ProcessedFolder].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'd:\FARRMS_DataSrc\TRMTracker_Trunk_CLR\IceForwardPrice\error\', '\Package.Variables[User::PS_ErrorFolder].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'testuser', '\Package.Variables[User::PS_UrlUserName].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'testpw', '\Package.Variables[User::PS_UrlPassword].Properties[Value]', 'String'
UNION
SELECT 'PKG_IcePriceCurveImport', 'both', '\Package.Variables[User::PS_DownloadGasOrPower].Properties[Value]', 'String'










