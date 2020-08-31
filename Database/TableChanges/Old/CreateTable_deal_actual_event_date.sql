SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_actual_event_date]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_actual_event_date] (
    	[deal_actual_event_date_id]     INT IDENTITY(1, 1) NOT NULL,
    	[source_deal_detail_id]			INT NULL,-- REFERENCES source_deal_detail(source_deal_detail_id) 
		split_deal_actuals_id			INT NULL,
    	[event_type]                    INT NULL,
    	[event_date]                    DATETIME NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_actual_event_date EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_actual_event_date]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_actual_event_date]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_actual_event_date]
ON [dbo].[deal_actual_event_date]
FOR UPDATE
AS
    UPDATE deal_actual_event_date
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_actual_event_date t
      INNER JOIN DELETED u ON t.[deal_actual_event_date_id] = u.[deal_actual_event_date_id]
GO