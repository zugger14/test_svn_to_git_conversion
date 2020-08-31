SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[module_events]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[module_events]
    (
    	[module_events_id]  INT IDENTITY(1, 1) NOT NULL,
    	[modules_id]        INT NULL,
    	[event_id]          INT NULL,
    	[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]       VARCHAR(50) NULL,
    	[update_ts]         DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table module_events EXISTS'
END
 
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_module_events]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_module_events]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_module_events]
ON [dbo].[module_events]
FOR UPDATE
AS
    UPDATE module_events
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM module_events t
      INNER JOIN DELETED u ON t.module_events_id = u.module_events_id
GO