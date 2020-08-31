SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_inventory_accounting_log]'))
	DROP TRIGGER [dbo].[TRGUPD_inventory_accounting_log]
GO

CREATE TRIGGER [dbo].[TRGUPD_inventory_accounting_log]
ON [dbo].[inventory_accounting_log]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE inventory_accounting_log
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM inventory_accounting_log t
		INNER JOIN DELETED u ON t.mtm_test_run_log_id = u.mtm_test_run_log_id
	END
END
GO
