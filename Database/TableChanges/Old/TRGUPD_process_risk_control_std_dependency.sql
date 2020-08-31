SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_control_std_dependency]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_control_std_dependency]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_control_std_dependency]
ON [dbo].[process_risk_control_std_dependency]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_control_std_dependency
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_risk_control_std_dependency t
		INNER JOIN DELETED u ON t.requirements_revision_dependency_id = u.requirements_revision_dependency_id
	END
END
GO
