SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_legal_entity]'))
	DROP TRIGGER [dbo].[TRGUPD_source_legal_entity]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_legal_entity]
ON [dbo].[source_legal_entity]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_legal_entity
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_legal_entity t
		INNER JOIN DELETED u ON t.source_legal_entity_id = u.source_legal_entity_id
	END
END
GO

