SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_volume_unit_conversion]'))
	DROP TRIGGER [dbo].[TRGUPD_volume_unit_conversion]
GO

CREATE TRIGGER [dbo].[TRGUPD_volume_unit_conversion]
ON [dbo].[volume_unit_conversion]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE volume_unit_conversion
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM volume_unit_conversion t
		INNER JOIN DELETED u ON t.from_source_uom_id = u.from_source_uom_id AND t.to_source_uom_id = u.to_source_uom_id
	END
END
GO
