SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_conversion_type]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_conversion_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_conversion_type]
ON [dbo].[ems_conversion_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_conversion_type
		SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
		FROM ems_conversion_type t
		INNER JOIN DELETED u ON t.ems_conversion_type_id = u.ems_conversion_type_id
	END
END
GO
