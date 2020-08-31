SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_transportation_rate_schedule]'))
	DROP TRIGGER [dbo].[TRGUPD_transportation_rate_schedule]
GO

CREATE TRIGGER [dbo].[TRGUPD_transportation_rate_schedule]
ON [dbo].[transportation_rate_schedule]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE transportation_rate_schedule
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM transportation_rate_schedule t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
