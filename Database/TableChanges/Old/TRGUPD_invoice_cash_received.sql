SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_invoice_cash_received]'))
	DROP TRIGGER [dbo].[TRGUPD_invoice_cash_received]
GO

CREATE TRIGGER [dbo].[TRGUPD_invoice_cash_received]
ON [dbo].[invoice_cash_received]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE invoice_cash_received
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM invoice_cash_received t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
