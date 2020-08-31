SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_mv90_data]'))
	DROP TRIGGER [dbo].[TRGUPD_mv90_data]
GO

CREATE TRIGGER [dbo].[TRGUPD_mv90_data]
ON [dbo].[mv90_data]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE mv90_data
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM mv90_data t
		INNER JOIN DELETED u ON t.meter_data_id = u.meter_data_id
	END
END
GO