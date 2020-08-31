SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_exclude_st_forecast_dates]'))
	DROP TRIGGER [dbo].[TRGUPD_exclude_st_forecast_dates]
GO

CREATE TRIGGER [dbo].[TRGUPD_exclude_st_forecast_dates]
ON [dbo].[exclude_st_forecast_dates]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE exclude_st_forecast_dates
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM exclude_st_forecast_dates t
		INNER JOIN DELETED u ON t.exclude_st_forecast_dates_id = u.exclude_st_forecast_dates_id
	END
END
GO
