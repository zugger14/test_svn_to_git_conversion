
--clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_ICEDeal')

--apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PKG_ICEDeal', '\IceDeal\Package', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ICEDeal', 'D:\TrmMasterSSIS\IceDeal\Data\IceDealInput\', '\Package.Variables[User::PS_XMLInputFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_ICEDeal', 'D:\TrmMasterSSIS\IceDeal\ICEDealXSD.xsd', '\Package.Variables[User::PS_XMLXSDLocation].Properties[Value]', 'String'



--SELECT  * FROM ssis_configurations sc WHERE sc.ConfigurationFilter LIKE 'PKG_ICEDeal'

