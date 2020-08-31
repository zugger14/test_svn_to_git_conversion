SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_requirements_main]'))
	DROP TRIGGER [dbo].[TRGUPD_process_requirements_main]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_requirements_main]
ON [dbo].[process_requirements_main]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_requirements_main
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_requirements_main t
		INNER JOIN DELETED u ON t.requirements_id = u.requirements_id
	END
END
GO
