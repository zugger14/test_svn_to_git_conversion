SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_dataset_paramset]'))
	DROP TRIGGER [dbo].[TRGUPD_report_dataset_paramset]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_dataset_paramset]
ON [dbo].[report_dataset_paramset]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE report_dataset_paramset
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM report_dataset_paramset t
		INNER JOIN DELETED u ON t.report_dataset_paramset_id = u.report_dataset_paramset_id
	END
END
GO
