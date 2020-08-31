SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_deal_cash_settlement]'))
	DROP TRIGGER [dbo].[TRGUPD_source_deal_cash_settlement]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_deal_cash_settlement]
ON [dbo].[source_deal_cash_settlement]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_deal_cash_settlement
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_deal_cash_settlement t
		INNER JOIN DELETED u ON t.source_deal_settlement_id = u.source_deal_settlement_id
	END
END
GO
