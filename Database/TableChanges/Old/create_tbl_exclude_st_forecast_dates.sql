SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[exclude_st_forecast_dates]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].exclude_st_forecast_dates
    (
    [exclude_st_forecast_dates_id] INT IDENTITY(1, 1) NOT NULL,
    [term_start] DATETIME NULL,
    [term_end] DATETIME NULL,
    [group_id] INT,
    [create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts] DATETIME NULL DEFAULT GETDATE(),
    [update_user] VARCHAR(50) NULL,
    [update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table exclude_st_forecast_dates EXISTS'
END
 
GO

