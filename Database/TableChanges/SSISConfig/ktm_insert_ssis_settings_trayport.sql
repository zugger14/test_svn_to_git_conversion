
-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_Trayport')

-- apply new settings
INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)

SELECT 'PKG_Trayport',	'D:\essentssis\Trayport\Trayport_Format.xsd',	'\Package.Variables[User::PS_XSDFormat].Properties[Value]',	'String'
UNION ALL
SELECT 'PKG_Trayport',	'D:\essentssis\Trayport\TrayPortOutput', '\Package.Variables[User::PS_XMLSucessFolder].Properties[Value]',	'String'
UNION ALL
SELECT 'PKG_Trayport',	'D:\essentssis\Trayport\TrayPortInput', '\Package.Variables[User::PS_XMLInputFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_Trayport',	'D:\essentssis\Trayport\TrayPortError', '\Package.Variables[User::PS_XML_ErrorFolder].Properties[Value]', 'String'
UNION ALL
SELECT 'PKG_Trayport',	'\Trayport', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'

--update import path
UPDATE connection_string SET import_path = 'D:\EssentSSIS\'