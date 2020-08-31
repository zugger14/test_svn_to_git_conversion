SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_writer_table]'))
	DROP TRIGGER [dbo].[TRGUPD_report_writer_table]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_writer_table]
ON [dbo].[report_writer_table]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE report_writer_table
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM report_writer_table t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
