SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_deal_external]'))
	DROP TRIGGER [dbo].[TRGUPD_source_deal_external]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_deal_external]
ON [dbo].[source_deal_external]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_deal_external
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_deal_external t
		INNER JOIN DELETED u ON t.external_id = u.external_id
	END
END
GO
