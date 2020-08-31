SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_invoice_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_invoice_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_invoice_detail]
ON [dbo].[invoice_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE invoice_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM invoice_detail t
		INNER JOIN DELETED u ON t.invoice_detail_id = u.invoice_detail_id
	END
END
GO
