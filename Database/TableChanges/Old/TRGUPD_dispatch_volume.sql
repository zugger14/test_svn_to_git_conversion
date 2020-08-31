SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_dispatch_volume]'))
	DROP TRIGGER [dbo].[TRGUPD_dispatch_volume]
GO

CREATE TRIGGER [dbo].[TRGUPD_dispatch_volume]
ON [dbo].[dispatch_volume]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE dispatch_volume
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM dispatch_volume t
		INNER JOIN DELETED u ON t.dispatch_volume_id = u.dispatch_volume_id
	END
END
GO
