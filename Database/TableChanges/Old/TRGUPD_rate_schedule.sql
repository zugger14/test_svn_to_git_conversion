SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rate_schedule]'))
	DROP TRIGGER [dbo].[TRGUPD_rate_schedule]
GO

CREATE TRIGGER [dbo].[TRGUPD_rate_schedule]
ON [dbo].[rate_schedule]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE rate_schedule
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM rate_schedule t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
