SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_working_days]'))
	DROP TRIGGER [dbo].[TRGUPD_working_days]
GO

CREATE TRIGGER [dbo].[TRGUPD_working_days]
ON [dbo].[working_days]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE working_days
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM working_days t
		INNER JOIN DELETED u ON t.block_value_id = u.block_value_id AND t.[weekday] = u.[weekday]
	END
END
GO
