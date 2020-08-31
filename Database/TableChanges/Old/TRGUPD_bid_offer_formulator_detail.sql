SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_bid_offer_formulator_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_bid_offer_formulator_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_bid_offer_formulator_detail]
ON [dbo].[bid_offer_formulator_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE bid_offer_formulator_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM bid_offer_formulator_detail t
		INNER JOIN DELETED u ON t.bid_offer_detail_id = u.bid_offer_detail_id
	END
END
GO




