SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_cached_curves]'))
	DROP TRIGGER [dbo].[TRGUPD_cached_curves]
GO

CREATE TRIGGER [dbo].[TRGUPD_cached_curves]
ON [dbo].[cached_curves]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE cached_curves
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM cached_curves t
		INNER JOIN DELETED u ON t.ROWID = u.ROWID
	END
END