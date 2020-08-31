SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[st_forecast_group_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[st_forecast_group_header]
    (
    [st_forecast_group_header_id] INT IDENTITY(1, 1) NOT NULL,
    [st_forecast_group_id] INT NULL,
    [uom_id] INT  NULL,
    [granularity_id] INT NULL,
    [multiplier] INT NULL,
    [delivery_redelivery] VARCHAR(500),
    [create_user]    VARCHAR(50) NULL,
    [create_ts]      DATETIME NULL,
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
    
    IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND tc.Table_Name = 'st_forecast_group_header'           --table name
                    AND ccu.COLUMN_NAME = 'st_forecast_group_header_id'          --column name where FK constaint is to be created
	)
	ALTER TABLE [dbo].st_forecast_group_header 
		WITH NOCHECK ADD CONSTRAINT [PK_st_forecast_group_header_id] PRIMARY KEY(st_forecast_group_header_id)

	ALTER TABLE dbo.st_forecast_group_header ADD CONSTRAINT
		DF_st_forecast_group_header_create_ts DEFAULT GETDATE() FOR create_ts


	ALTER TABLE dbo.st_forecast_group_header ADD CONSTRAINT
		DF_st_forecast_group_header_create_user DEFAULT dbo.FNADBUser() FOR create_user

END
ELSE
BEGIN
    PRINT 'Table st_forecast_group_header EXISTS'
END
GO