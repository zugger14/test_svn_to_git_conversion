SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_stack_unit_map]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_stack_unit_map]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_stack_unit_map]
ON [dbo].[ems_stack_unit_map]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_stack_unit_map
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_stack_unit_map t
		INNER JOIN DELETED u ON t.ID = u.ID
	END
END
GO
