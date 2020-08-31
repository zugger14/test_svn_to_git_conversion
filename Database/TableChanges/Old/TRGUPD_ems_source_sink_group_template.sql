SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_source_sink_group_template]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_source_sink_group_template]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_source_sink_group_template]
ON [dbo].[ems_source_sink_group_template]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_source_sink_group_template
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_source_sink_group_template t
		INNER JOIN DELETED u ON t.source_group_template_id = u.source_group_template_id
	END
END
GO

