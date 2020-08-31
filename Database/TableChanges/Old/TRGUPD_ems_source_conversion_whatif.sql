SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_source_conversion_whatif]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_source_conversion_whatif]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_source_conversion_whatif]
ON [dbo].[ems_source_conversion_whatif]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_source_conversion_whatif
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_source_conversion_whatif t
		INNER JOIN DELETED u ON t.conversion_id = u.conversion_id
	END
END
GO
