
-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN('PKG_EndurDataImport')

INSERT INTO ssis_configurations (ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'D:\FARRMS_DataSrc\TRMTracker_New_Framework\EndurDataImport\Data' AS [ConfiguredValue], N'\Package.Variables[User::PS_Workspace].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'User_Files' AS [ConfiguredValue], N'\Package.Variables[User::PS_UserFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'Temp' AS [ConfiguredValue], N'\Package.Variables[User::PS_TempProcessingFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'rweAll' AS [ConfiguredValue], N'\Package.Variables[User::PS_SetupFileName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'n' AS [ConfiguredValue], N'\Package.Variables[User::PS_SendMail].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'Processed_' AS [ConfiguredValue], N'\Package.Variables[User::PS_ProcessedFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'Error_' AS [ConfiguredValue], N'\Package.Variables[User::PS_ErrorFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'Endur_Files' AS [ConfiguredValue], N'\Package.Variables[User::PS_EndurFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] UNION ALL
SELECT N'PKG_EndurDataImport' AS [ConfigurationFilter], N'New_' AS [ConfiguredValue], N'\Package.Variables[User::PS_AllFilesFolderName].Properties[Value]' AS [PackagePath], N'String' AS [ConfiguredValueType] 

UPDATE connection_string SET import_path = 'D:\FARRMS_SPTFiles\SSIS\TRMTracker_New_Framework'