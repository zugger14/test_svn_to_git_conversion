-- clear existing settings
DELETE FROM   [ssis_configurations] WHERE  ConfigurationFilter IN ('PKG_IceDealImport')

-- apply new settings
INSERT INTO [ssis_configurations](ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
SELECT 'PKG_IceDealImport', '\IceDeal\Package\', '\Package.Variables[User::PS_packageSubDir].Properties[Value]', 'String'
UNION
SELECT 'PKG_IceDealImport', 'd:\FARRMS_DataSrc\TRMTracker_trunk_clr\IceDeal\import\', '\Package.Variables[User::PS_ImportFolder].Properties[Value]', 'String'
UNION
SELECT 'PKG_IceDealImport', 'd:\FARRMS_DataSrc\TRMTracker_trunk_clr\IceDeal\processed', '\Package.Variables[User::PS_ProcessedFolder].Properties[Value]', 'String'
UNION
SELECT 'PKG_IceDealImport', 'd:\FARRMS_DataSrc\TRMTracker_trunk_clr\IceDeal\error', '\Package.Variables[User::PS_ErrorFolder].Properties[Value]', 'String'



