SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_standard_main]'))
	DROP TRIGGER [dbo].[TRGUPD_process_standard_main]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_standard_main]
ON [dbo].[process_standard_main]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_standard_main
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_standard_main t
		INNER JOIN DELETED u ON t.standard_id = u.standard_id
	END
END
GO
