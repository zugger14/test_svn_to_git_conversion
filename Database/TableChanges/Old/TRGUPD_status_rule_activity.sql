SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_status_rule_activity]'))
	DROP TRIGGER [dbo].[TRGUPD_status_rule_activity]
GO

CREATE TRIGGER [dbo].[TRGUPD_status_rule_activity]
ON [dbo].[status_rule_activity]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE status_rule_activity
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM status_rule_activity t
		INNER JOIN DELETED u ON t.status_rule_activity_id = u.status_rule_activity_id
	END
END
GO
