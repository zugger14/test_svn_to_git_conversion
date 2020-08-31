SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_meter_counterparty]'))
	DROP TRIGGER [dbo].[TRGUPD_meter_counterparty]
GO

CREATE TRIGGER [dbo].[TRGUPD_meter_counterparty]
ON [dbo].[meter_counterparty]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE meter_counterparty
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM meter_counterparty t
		INNER JOIN DELETED u ON t.meter_counterparty_id = u.meter_counterparty_id
	END
END
GO
