SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_control_header]'))
	DROP TRIGGER [dbo].[TRGUPD_process_control_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_control_header]
ON [dbo].[process_control_header]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_control_header
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_control_header t
		INNER JOIN DELETED u ON t.process_id = u.process_id
	END
END
GO
