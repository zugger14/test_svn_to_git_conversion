SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_static_data_type]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_static_data_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_static_data_type]
ON [dbo].[ems_static_data_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_static_data_type
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_static_data_type t
		INNER JOIN DELETED u ON t.type_id = u.type_id
	END
END
GO
