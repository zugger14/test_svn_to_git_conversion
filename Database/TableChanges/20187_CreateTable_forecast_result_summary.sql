SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[forecast_result_summary]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[forecast_result_summary](
    	[forecast_result_summary_id]     INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[process_id]                     VARCHAR(200) NOT NULL,
    	[forecast_mapping_id]            INT REFERENCES forecast_mapping(forecast_mapping_id) NOT NULL,
    	[is_approved]                    INT NULL DEFAULT 0,
    	[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                    VARCHAR(50) NULL,
    	[update_ts]                      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table forecast_result_summary EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_forecast_result_summary]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_result_summary]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_result_summary]
ON [dbo].[forecast_result_summary]
FOR UPDATE
AS
    UPDATE forecast_result_summary
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_result_summary t
      INNER JOIN DELETED u ON t.[forecast_result_summary_id] = u.[forecast_result_summary_id]
GO