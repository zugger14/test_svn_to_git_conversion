SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_recorder_generator_map_submeter]'))
	DROP TRIGGER [dbo].[TRGUPD_recorder_generator_map_submeter]
GO

CREATE TRIGGER [dbo].[TRGUPD_recorder_generator_map_submeter]
ON [dbo].[recorder_generator_map_submeter]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE recorder_generator_map_submeter
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM recorder_generator_map_submeter t
		INNER JOIN DELETED u ON t.ID = u.ID
	END
END
GO
