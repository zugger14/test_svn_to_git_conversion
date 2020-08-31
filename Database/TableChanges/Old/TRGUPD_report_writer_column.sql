SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_writer_column]'))
	DROP TRIGGER [dbo].[TRGUPD_report_writer_column]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_writer_column]
ON [dbo].[report_writer_column]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE report_writer_column
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM report_writer_column t
		INNER JOIN DELETED u ON t.report_column_id = u.report_column_id
	END
END
GO
