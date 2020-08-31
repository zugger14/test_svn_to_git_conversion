SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_dashboard_report_template_group]'))
	DROP TRIGGER [dbo].[TRGUPD_dashboard_report_template_group]
GO

CREATE TRIGGER [dbo].[TRGUPD_dashboard_report_template_group]
ON [dbo].[dashboard_report_template_group]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE dashboard_report_template_group
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM dashboard_report_template_group t
		INNER JOIN DELETED u ON t.report_template_group_id = u.report_template_group_id
	END
END
GO
