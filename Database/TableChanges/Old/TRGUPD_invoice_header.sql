SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_invoice_header]'))
	DROP TRIGGER [dbo].[TRGUPD_invoice_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_invoice_header]
ON [dbo].[invoice_header]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE invoice_header
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM invoice_header t
		INNER JOIN DELETED u ON t.invoice_id = u.invoice_id
	END
END
GO
