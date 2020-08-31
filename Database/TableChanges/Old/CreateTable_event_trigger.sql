SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[event_trigger]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[event_trigger]
    (
    	[event_trigger_id]  INT IDENTITY(1, 1) NOT NULL,
    	[modules_event_id]  INT NULL,
    	[alert_id]          INT NULL,
    	[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]       VARCHAR(50) NULL,
    	[update_ts]         DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table event_trigger EXISTS'
END
 
GO

IF OBJECT_ID('[dbo].[TRGUPD_event_trigger]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_event_trigger]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_event_trigger]
ON [dbo].[event_trigger]
FOR UPDATE
AS
    UPDATE event_trigger
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM event_trigger t
      INNER JOIN DELETED u ON t.event_trigger_id = u.event_trigger_id
GO