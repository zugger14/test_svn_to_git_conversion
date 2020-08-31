SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_finalize_approve_test_run_log]'))
	DROP TRIGGER [dbo].[TRGUPD_finalize_approve_test_run_log]
GO

CREATE TRIGGER [dbo].[TRGUPD_finalize_approve_test_run_log]
ON [dbo].[finalize_approve_test_run_log]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE finalize_approve_test_run_log
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM finalize_approve_test_run_log t
		INNER JOIN DELETED u ON t.finalize_test_run_log_id = u.finalize_test_run_log_id
	END
END
GO
