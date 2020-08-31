SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_load_forecast]'))
	DROP TRIGGER [dbo].[TRGUPD_load_forecast]
GO

CREATE TRIGGER [dbo].[TRGUPD_load_forecast]
ON [dbo].[load_forecast]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE load_forecast
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM load_forecast t
		INNER JOIN DELETED u ON t.load_forecast_id = u.load_forecast_id
	END
END
GO
