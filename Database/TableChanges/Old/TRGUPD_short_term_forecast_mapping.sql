SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_short_term_forecast_mapping]'))
	DROP TRIGGER [dbo].[TRGUPD_short_term_forecast_mapping]
GO

CREATE TRIGGER [dbo].[TRGUPD_short_term_forecast_mapping]
ON [dbo].[short_term_forecast_mapping]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE short_term_forecast_mapping
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM short_term_forecast_mapping t
		INNER JOIN DELETED u ON t.short_term_forecast_mapping_id = u.short_term_forecast_mapping_id
	END
END
GO
