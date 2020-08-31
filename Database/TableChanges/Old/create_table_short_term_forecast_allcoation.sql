SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[short_term_forecast_allocation]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[short_term_forecast_allocation]
    (
    [short_term_forecast_allocation_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	[st_forecast_group_id] INT REFERENCES static_data_value(value_id) NOT NULL,
	[source_deal_header_id] INT REFERENCES source_deal_header(source_deal_header_id) NOT NULL,
	[percentage_allocation] FLOAT,
    [create_user]    VARCHAR(50) NULL,
    [create_ts]      DATETIME NULL,
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )

	ALTER TABLE dbo.[short_term_forecast_allocation] ADD CONSTRAINT
		DF_short_term_forecast_allocation_create_ts DEFAULT GETDATE() FOR create_ts

	ALTER TABLE dbo.[short_term_forecast_allocation] ADD CONSTRAINT
		DF_short_term_forecast_allocation_create_user DEFAULT dbo.FNADBUser() FOR create_user

END
ELSE
BEGIN
    PRINT 'Table short_term_forecast_allocation EXISTS'
END

GO



