SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_internal_portfolio]'))
	DROP TRIGGER [dbo].[TRGUPD_source_internal_portfolio]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_internal_portfolio]
ON [dbo].[source_internal_portfolio]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_internal_portfolio
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_internal_portfolio t
		INNER JOIN DELETED u ON t.source_internal_portfolio_id = u.source_internal_portfolio_id
	END
END
GO

