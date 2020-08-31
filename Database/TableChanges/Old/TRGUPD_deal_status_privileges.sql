SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_status_privileges]'))
	DROP TRIGGER [dbo].[TRGUPD_deal_status_privileges]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_status_privileges]
ON [dbo].[deal_status_privileges]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE deal_status_privileges
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM deal_status_privileges t
		INNER JOIN DELETED u ON t.deal_status_privilege_ID = u.deal_status_privilege_ID
	END
END
GO
