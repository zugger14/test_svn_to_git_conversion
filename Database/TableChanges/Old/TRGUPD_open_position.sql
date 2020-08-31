SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_open_position]'))
	DROP TRIGGER [dbo].[TRGUPD_open_position]
GO

CREATE TRIGGER [dbo].[TRGUPD_open_position]
ON [dbo].[open_position]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE open_position
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM open_position t
		INNER JOIN DELETED u ON t.open_position_id = u.open_position_id
	END
END
GO
