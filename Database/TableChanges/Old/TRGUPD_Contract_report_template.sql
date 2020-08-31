SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_Contract_report_template]'))
	DROP TRIGGER [dbo].[TRGUPD_Contract_report_template]
GO

CREATE TRIGGER [dbo].[TRGUPD_Contract_report_template]
ON [dbo].[Contract_report_template]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE Contract_report_template
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM Contract_report_template t
		INNER JOIN DELETED u ON t.template_id = u.template_id
	END
END
GO

