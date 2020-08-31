-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_RDBInterface')

-- apply new settings
INSERT ssis_configurations(ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
      SELECT 'PRJ_RDBInterface', '\RDB', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
      UNION ALL
	  SELECT 'PRJ_RDBInterface', 'D:\TEMP\RDB_Output', '\Package.Variables[User::OutputPATH].Properties[Value]', 'String'
	  UNION ALL 
      SELECT 'PRJ_RDBInterface','D:\TEMP\RDB_Output - Copy', '\Package.Variables[User::Copy_OutputPATH].Properties[Value]', 'String'
