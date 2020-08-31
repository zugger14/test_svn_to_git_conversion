SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_short_term_forecast_allocation]'))
	DROP TRIGGER [dbo].[TRGUPD_short_term_forecast_allocation]
GO

CREATE TRIGGER [dbo].[TRGUPD_short_term_forecast_allocation]
ON [dbo].[short_term_forecast_allocation]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE short_term_forecast_allocation
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM short_term_forecast_allocation t
		INNER JOIN DELETED u ON t.short_term_forecast_allocation_id = u.short_term_forecast_allocation_id
	END
END
GO
