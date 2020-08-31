SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_requirements_assignment]'))
	DROP TRIGGER [dbo].[TRGUPD_process_requirements_assignment]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_requirements_assignment]
ON [dbo].[process_requirements_assignment]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_requirements_assignment
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_requirements_assignment t
		INNER JOIN DELETED u ON t.requirement_assignment_id = u.requirement_assignment_id
	END
END
GO
