SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_save_confirm_status]'))
	DROP TRIGGER [dbo].[TRGUPD_save_confirm_status]
GO

CREATE TRIGGER [dbo].[TRGUPD_save_confirm_status]
ON [dbo].[save_confirm_status]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE save_confirm_status
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM save_confirm_status t
		INNER JOIN DELETED u ON t.confirm_id = u.confirm_id
	END
END
GO

 
