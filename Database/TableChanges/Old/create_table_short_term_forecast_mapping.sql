SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[short_term_forecast_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[short_term_forecast_mapping]
    (
	[short_term_forecast_mapping_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	[st_forecast_group_id] INT REFERENCES static_data_value(value_id) NOT NULL,
	[location] INT,
	[commodity_id] INT,
    [counterparty_id] INT,
    [IsProfiled] CHAR(1),
    [create_user]    VARCHAR(50) NULL,
    [create_ts]      DATETIME NULL,
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
    
	ALTER TABLE dbo.[short_term_forecast_mapping] ADD CONSTRAINT
		DF_short_term_forecast_mapping_create_ts DEFAULT GETDATE() FOR create_ts

	ALTER TABLE dbo.[short_term_forecast_mapping] ADD CONSTRAINT
		DF_short_term_forecast_mapping_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
ELSE
BEGIN
    PRINT 'Table short_term_forecast_mapping  EXISTS'
END

GO


