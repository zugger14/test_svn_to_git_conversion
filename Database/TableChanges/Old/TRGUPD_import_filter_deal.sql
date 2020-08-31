SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_import_filter_deal]'))
	DROP TRIGGER [dbo].[TRGUPD_import_filter_deal]
GO

CREATE TRIGGER [dbo].[TRGUPD_import_filter_deal]
ON [dbo].[import_filter_deal]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE import_filter_deal
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM import_filter_deal t
		INNER JOIN DELETED u ON t.import_filter_id = u.import_filter_id
	END
END
GO


