IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_price_curve'      --table name
                      AND COLUMN_NAME = 'create_user'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[source_price_curve] 
	ADD CONSTRAINT [DF_source_price_curve_create_user] DEFAULT([dbo].[FNADBUser]()) FOR [create_user]
END 
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'source_price_curve'      --table name
                      AND COLUMN_NAME = 'create_ts'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[source_price_curve] 
	ADD CONSTRAINT [DF_source_price_curve_create_ts] DEFAULT(GETDATE()) FOR [create_ts]
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'curve_volatility'      --table name
                      AND COLUMN_NAME = 'create_user'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[curve_volatility] 
	ADD CONSTRAINT [DF_curve_volatility_create_user] DEFAULT([dbo].[FNADBUser]()) FOR [create_user]
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'curve_volatility'      --table name
                      AND COLUMN_NAME = 'create_ts'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[curve_volatility]
	ADD CONSTRAINT [DF_curve_volatility_create_ts] DEFAULT(GETDATE()) FOR [create_ts]
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'curve_correlation'      --table name
                      AND COLUMN_NAME = 'create_user'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[curve_correlation] 
	ADD CONSTRAINT [DF_curve_correlation_create_user] DEFAULT([dbo].[FNADBUser]()) FOR [create_user]
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'curve_correlation'      --table name
                      AND COLUMN_NAME = 'create_ts'				 --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[curve_correlation] 
	ADD CONSTRAINT [DF_curve_correlation_create_ts] DEFAULT(GETDATE()) FOR [create_ts]
END
GO





