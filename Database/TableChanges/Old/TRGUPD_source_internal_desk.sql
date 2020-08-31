SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_internal_desk]'))
	DROP TRIGGER [dbo].[TRGUPD_source_internal_desk]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_internal_desk]
ON [dbo].[source_internal_desk]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_internal_desk
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_internal_desk t
		INNER JOIN DELETED u ON t.source_internal_desk_id = u.source_internal_desk_id
	END
END
GO
