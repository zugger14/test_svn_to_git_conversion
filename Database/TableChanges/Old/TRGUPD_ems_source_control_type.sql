SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_source_control_type]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_source_control_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_source_control_type]
ON [dbo].[ems_source_control_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_source_control_type
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_source_control_type t
		INNER JOIN DELETED u ON t.source_control_id = u.source_control_id
	END
END
GO
