SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[calendar_events]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].calendar_events(
		[calendar_event_id]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[name]					VARCHAR(50) NOT NULL,
		[description]			VARCHAR(1000),
		[workflow_id]			INT,
		[alert_id]				INT,
		[reminder]				INT,
		[snoozed]				DATETIME,
		[start_date]			DATETIME NOT NULL,
		[end_date]				DATETIME NOT NULL,
		[rec_type]				VARCHAR(4000),
		[event_parent_id]		VARCHAR(200),
		[event_length]			VARCHAR(200),
		[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].calender_events EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_calendar_events]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_calendar_events]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_calendar_events]
ON [dbo].[calendar_events]
FOR UPDATE
AS
    UPDATE calendar_events
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM calendar_events t
      INNER JOIN DELETED u ON t.calendar_event_id = u.calendar_event_id
GO