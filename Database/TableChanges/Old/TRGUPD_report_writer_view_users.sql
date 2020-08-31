SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_writer_view_users]'))
	DROP TRIGGER [dbo].[TRGUPD_report_writer_view_users]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_writer_view_users]
ON [dbo].[report_writer_view_users]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE report_writer_view_users
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM report_writer_view_users t
		INNER JOIN DELETED u ON t.functional_users_id = u.functional_users_id
	END
END
GO
