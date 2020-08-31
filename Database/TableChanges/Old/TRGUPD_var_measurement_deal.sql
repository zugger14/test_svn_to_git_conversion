SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_var_measurement_deal]'))
	DROP TRIGGER [dbo].[TRGUPD_var_measurement_deal]
GO

CREATE TRIGGER [dbo].[TRGUPD_var_measurement_deal]
ON [dbo].[var_measurement_deal]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE var_measurement_deal
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM var_measurement_deal t
		INNER JOIN DELETED u ON t.var_measurement_deal_id = u.var_measurement_deal_id
	END
END
GO
