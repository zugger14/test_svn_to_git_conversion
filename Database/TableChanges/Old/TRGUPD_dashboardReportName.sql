SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_dashboardReportName]'))
	DROP TRIGGER [dbo].[TRGUPD_dashboardReportName]
GO

CREATE TRIGGER [dbo].[TRGUPD_dashboardReportName]
ON [dbo].[dashboardReportName]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE dashboardReportName
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM dashboardReportName t
		INNER JOIN DELETED u ON t.template_id = u.template_id
	END
END
GO
