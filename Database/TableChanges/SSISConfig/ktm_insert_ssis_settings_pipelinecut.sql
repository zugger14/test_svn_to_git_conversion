DELETE FROM ssis_configurations WHERE ConfigurationFilter = 'PRJ_PipelineCut'

INSERT INTO ssis_configurations(ConfigurationFilter, ConfiguredValue, PackagePath, ConfiguredValueType)
SELECT 'PRJ_PipelineCut', 'D:\PNMSSIS\pipeline_cut\pipline_cut_files\Output\Processed',	'\Package.Variables[User::PS_ProcessedFilePath].Properties[Value]',	'String'
UNION ALL
SELECT 'PRJ_PipelineCut', '\pipeline_cut\Packages',	'\Package.Variables[User::PS_PackageSubDir].Properties[Value]',	'String'
UNION ALL
SELECT 'PRJ_PipelineCut', 'False', '\Package.Variables[User::PS_HasHeader].Properties[Value]', 'Boolean'
UNION ALL
SELECT 'PRJ_PipelineCut', 'D:\PNMSSIS\pipeline_cut\pipline_cut_files\Output\Error',	'\Package.Variables[User::PS_ErrorFilePath].Properties[Value]',	'String'
UNION ALL
SELECT 'PRJ_PipelineCut', 'D:\PNMSSIS\pipeline_cut\pipline_cut_files\Input', '\Package.Variables[User::PS_DataFilePath].Properties[Value]', 'String'

UPDATE connection_string SET import_path = 'd:\PNMSSIS'

GO
