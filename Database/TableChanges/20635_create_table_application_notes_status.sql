SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_notes_status]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_notes_status]
    (
    	[application_notes_status_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[application_notes_id]			INT NULL,
		[status_id]						INT NULL,
		[status_date]					DATETIME NULL,
		[comments]					VARCHAR(1000) NULL, 
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table application_notes_status EXISTS'
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_application_notes_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[application_notes_status]'))
BEGIN
	ALTER TABLE [dbo].[application_notes_status] WITH CHECK ADD CONSTRAINT [FK_application_notes_id] 
	FOREIGN KEY([application_notes_id])
	REFERENCES [dbo].[application_notes] ([notes_id])

END

IF OBJECT_ID('[dbo].[TRGUPD_application_notes_status]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_application_notes_status]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_application_notes_status]
ON [dbo].[application_notes_status]
FOR UPDATE
AS
    UPDATE application_notes_status
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM application_notes_status t
      INNER JOIN DELETED u ON t.[application_notes_status_id] = u.[application_notes_status_id]
GO