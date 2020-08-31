SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_settlement_invoice_log]'))
	DROP TRIGGER [dbo].[TRGUPD_process_settlement_invoice_log]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_settlement_invoice_log]
ON [dbo].[process_settlement_invoice_log]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_settlement_invoice_log
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_settlement_invoice_log t
		INNER JOIN DELETED u ON t.log_id = u.log_id
	END
END
GO
