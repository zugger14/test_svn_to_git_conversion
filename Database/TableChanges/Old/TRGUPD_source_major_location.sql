SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_major_location]'))
	DROP TRIGGER [dbo].[TRGUPD_source_major_location]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_major_location]
ON [dbo].[source_major_location]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_major_location
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_major_location t
		INNER JOIN DELETED u ON t.source_major_location_ID = u.source_major_location_ID
	END
END
GO
