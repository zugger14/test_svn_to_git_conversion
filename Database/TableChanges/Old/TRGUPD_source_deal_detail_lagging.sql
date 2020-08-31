SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_deal_detail_lagging]'))
	DROP TRIGGER [dbo].[TRGUPD_source_deal_detail_lagging]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_deal_detail_lagging]
ON [dbo].[source_deal_detail_lagging]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_deal_detail_lagging
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_deal_detail_lagging t
		INNER JOIN DELETED u ON t.source_deal_header_id = u.source_deal_header_id AND t.leg = u.leg
				AND t.term_start = u.term_start AND t.term_start_leg1 = u.term_start_leg1
	END
END
GO
