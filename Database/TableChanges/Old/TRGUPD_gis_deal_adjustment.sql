SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_gis_deal_adjustment]'))
	DROP TRIGGER [dbo].[TRGUPD_gis_deal_adjustment]
GO

CREATE TRIGGER [dbo].[TRGUPD_gis_deal_adjustment]
ON [dbo].[gis_deal_adjustment]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE gis_deal_adjustment
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM gis_deal_adjustment t
		INNER JOIN DELETED u ON t.source_deal_header_id = u.source_deal_header_id
	END
END
GO
