SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_Import_Transactions_Log]'))
	DROP TRIGGER [dbo].[TRGUPD_Import_Transactions_Log]
GO

CREATE TRIGGER [dbo].[TRGUPD_Import_Transactions_Log]
ON [dbo].[Import_Transactions_Log]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE Import_Transactions_Log
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
	FROM Import_Transactions_Log t
	INNER JOIN DELETED u ON t.Import_Transaction_log_id = u.Import_Transaction_log_id
	END
END
GO
