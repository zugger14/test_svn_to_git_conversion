SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_delivery_status]'))
	DROP TRIGGER [dbo].[TRGUPD_delivery_status]
GO

CREATE TRIGGER [dbo].[TRGUPD_delivery_status]
ON [dbo].[delivery_status]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE delivery_status
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM delivery_status t
		INNER JOIN DELETED u ON t.Id = u.Id
	END
END
GO
