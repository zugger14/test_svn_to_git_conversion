SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_requirements_revisions]'))
	DROP TRIGGER [dbo].[TRGUPD_process_requirements_revisions]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_requirements_revisions]
ON [dbo].[process_requirements_revisions]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_requirements_revisions
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_requirements_revisions t
		INNER JOIN DELETED u ON t.requirements_revision_id = u.requirements_revision_id
	END
END
GO
