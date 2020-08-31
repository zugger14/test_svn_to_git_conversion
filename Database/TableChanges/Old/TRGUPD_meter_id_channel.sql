SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_meter_id_channel]'))
	DROP TRIGGER [dbo].[TRGUPD_meter_id_channel]
GO

CREATE TRIGGER [dbo].[TRGUPD_meter_id_channel]
ON [dbo].[meter_id_channel]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE meter_id_channel
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM meter_id_channel t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
