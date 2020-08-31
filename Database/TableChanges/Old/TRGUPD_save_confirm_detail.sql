SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_save_confirm_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_save_confirm_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_save_confirm_detail]
ON [dbo].[save_confirm_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE save_confirm_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM save_confirm_detail t
		INNER JOIN DELETED u ON t.save_confirm_id = u.save_confirm_id
	END
END
GO


