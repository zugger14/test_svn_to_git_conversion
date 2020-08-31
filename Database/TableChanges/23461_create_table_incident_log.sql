
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[incident_log]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[incident_log](
		[incident_log_id]			INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[incident_type]				INT NOT NULL,
		[incident_description]		VARCHAR(300) NOT NULL,
		[incident_status]			INT NULL,
		[buyer_from]				INT NULL,
		[seller_to]					INT NULL,
		[location]					INT NULL,
		[date_initiated]			DATETIME NOT NULL,
		[date_closed]				DATETIME NULL,
		[trader]					INT NULL,
		[logistics]					INT NULL,
		
		[commodity]					INT NULL,
		[Origin]					INT NULL,
		[is_organic]				CHAR(1) NULL,
		[form]						INT NULL,
		[attribute1]				INT NULL,
		[attribute2]				INT NULL,
		[attribute3]				INT NULL,
		[attribute4]				INT NULL,
		[attribute5]				INT NULL,
		[crop_year]					INT NULL,
		
		[initial_assesment]			CHAR(1) NULL,
		[outcome_acceptable]		CHAR(1) NULL,
		[resolved_satisfactory]		CHAR(1) NULL,
		[non_confirming_delivered]	CHAR(1) NULL,
		[root_cause]				VARCHAR(500) NULL,
		[corrective_action]			VARCHAR(500) NULL,
		[preventive_action]			VARCHAR(500) NULL,
		
		[ref_incident_id]			INT NULL,
		[application_notes_id]		INT NOT NULL, 

		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL,

		CONSTRAINT fk_incident_log_incident_log_id FOREIGN KEY (ref_incident_id)
		REFERENCES incident_log(incident_log_id),
		CONSTRAINT fk_incident_log_application_notes_id FOREIGN KEY (application_notes_id)
		REFERENCES application_notes(notes_id)
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [dbo].incident_log EXISTS'
END


IF OBJECT_ID('[dbo].[TRGUPD_incident_log]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_incident_log]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_incident_log]
ON [dbo].[incident_log]
FOR UPDATE
AS
    UPDATE incident_log
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM incident_log t
      INNER JOIN DELETED u 
		ON t.incident_log_id = u.incident_log_id
GO