--add file_name in deal_detail_hour to store source file name
IF COL_LENGTH('source_price_curve_def', 'settlement_curve_id') IS NULL 
	ALTER TABLE dbo.source_price_curve_def ADD [settlement_curve_id] INT NULL
GO

IF COL_LENGTH('source_price_curve_def', 'time_zone') IS NULL 
	ALTER TABLE dbo.source_price_curve_def ADD [time_zone] INT NULL
GO

IF COL_LENGTH('source_price_curve_def', 'udf_block_group_id') IS NULL 
	ALTER TABLE dbo.source_price_curve_def ADD udf_block_group_id INT NULL
GO