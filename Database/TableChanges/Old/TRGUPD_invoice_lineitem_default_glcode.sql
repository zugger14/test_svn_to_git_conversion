SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_invoice_lineitem_default_glcode]'))
	DROP TRIGGER [dbo].[TRGUPD_invoice_lineitem_default_glcode]
GO

CREATE TRIGGER [dbo].[TRGUPD_invoice_lineitem_default_glcode]
ON [dbo].[invoice_lineitem_default_glcode]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE invoice_lineitem_default_glcode
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM invoice_lineitem_default_glcode t
		INNER JOIN DELETED u ON t.default_id = u.default_id
	END
END
GO
