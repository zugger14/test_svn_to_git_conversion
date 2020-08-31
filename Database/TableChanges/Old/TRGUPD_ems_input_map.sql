SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_input_map]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_input_map]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_input_map]
ON [dbo].[ems_input_map]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_input_map
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_input_map t
		INNER JOIN DELETED u ON t.source_input_id = u.source_input_id
	END
END
GO
