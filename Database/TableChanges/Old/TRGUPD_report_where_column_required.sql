SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_where_column_required]'))
	DROP TRIGGER [dbo].[TRGUPD_report_where_column_required]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_where_column_required]
ON [dbo].[report_where_column_required]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE report_where_column_required
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM report_where_column_required t
		INNER JOIN DELETED u ON t.table_name = u.table_name AND  u.column_name = t.column_name
	END
END
GO
