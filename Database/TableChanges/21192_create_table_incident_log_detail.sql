
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[incident_log_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[incident_log_detail](
		[incident_log_detail_id]	INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[incident_log_id]			INT NOT NULL,
		[incident_status]			INT NOT NULL,
		[incident_update_date]		DATETIME NULL,
		[comments]					VARCHAR(1000) NULL,
		[application_notes_id]		INT NULL, 

		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL,

		CONSTRAINT fk_incident_log_detail_incident_log_id FOREIGN KEY (incident_log_id)
		REFERENCES incident_log(incident_log_id),
		CONSTRAINT fk_incident_log_detail_application_notes_id FOREIGN KEY (application_notes_id)
		REFERENCES application_notes(notes_id)
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [dbo].incident_log_detail EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_incident_log_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_incident_log_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_incident_log_detail]
ON [dbo].[incident_log_detail]
FOR UPDATE
AS
    UPDATE incident_log_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM incident_log_detail t
      INNER JOIN DELETED u 
		ON t.incident_log_detail_id = u.incident_log_detail_id
GO