SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_static_data_value]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_static_data_value]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_static_data_value]
ON [dbo].[ems_static_data_value]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_static_data_value
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_static_data_value t
		INNER JOIN DELETED u ON t.value_id = u.value_id
	END
END
GO
