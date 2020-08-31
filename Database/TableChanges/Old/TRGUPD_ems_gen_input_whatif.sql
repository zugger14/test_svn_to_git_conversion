SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_gen_input_whatif]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_gen_input_whatif]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_gen_input_whatif]
ON [dbo].[ems_gen_input_whatif]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_gen_input_whatif
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_gen_input_whatif t
		INNER JOIN DELETED u ON t.ems_generator_id = u.ems_generator_id
	END
END
GO
