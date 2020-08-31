SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_input_characteristics]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_input_characteristics]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_input_characteristics]
ON [dbo].[ems_input_characteristics]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_input_characteristics
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_input_characteristics t
		INNER JOIN DELETED u ON t.type_char_id = u.type_char_id
	END
END
GO
