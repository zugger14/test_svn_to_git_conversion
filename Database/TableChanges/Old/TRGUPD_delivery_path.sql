SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_delivery_path]'))
	DROP TRIGGER [dbo].[TRGUPD_delivery_path]
GO

CREATE TRIGGER [dbo].[TRGUPD_delivery_path]
ON [dbo].[delivery_path]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE delivery_path
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM delivery_path t
		INNER JOIN DELETED u ON t.path_id = u.path_id
	END
END
GO
