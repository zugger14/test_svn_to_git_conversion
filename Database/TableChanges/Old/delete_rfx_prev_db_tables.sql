IF OBJECT_ID(N'[dbo].[data_source_columns]', N'U') IS NOT NULL
	DROP TABLE data_source_columns 

IF OBJECT_ID(N'[dbo].[reports]', N'U') IS NOT NULL
	DROP TABLE reports

IF OBJECT_ID(N'[dbo].[report_datasets]', N'U') IS NOT NULL	
	DROP TABLE report_datasets

IF OBJECT_ID(N'[dbo].[report_dataset_columns]', N'U') IS NOT NULL
	DROP TABLE report_dataset_columns 

IF OBJECT_ID(N'[dbo].[report_dataset_connection]', N'U') IS NOT NULL	
	DROP TABLE report_dataset_connection 
	
IF OBJECT_ID(N'[dbo].[report_dataset_relations]', N'U') IS NOT NULL	
	DROP TABLE report_dataset_relations 
	
IF OBJECT_ID(N'[dbo].[report_params]', N'U') IS NOT NULL	
	DROP TABLE report_params
	
IF OBJECT_ID(N'[dbo].[report_resultsets]', N'U') IS NOT NULL	
	DROP TABLE report_resultsets