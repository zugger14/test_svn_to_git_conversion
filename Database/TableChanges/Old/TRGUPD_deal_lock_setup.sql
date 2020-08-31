SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_lock_setup]'))
	DROP TRIGGER [dbo].[TRGUPD_deal_lock_setup]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_lock_setup]
ON [dbo].[deal_lock_setup]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE deal_lock_setup
			SET update_user = dbo.FNADBUser(),
				update_ts = GETDATE()
		FROM deal_lock_setup t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
