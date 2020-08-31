SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_recorder_properties]'))
	DROP TRIGGER [dbo].[TRGUPD_recorder_properties]
GO

CREATE TRIGGER [dbo].[TRGUPD_recorder_properties]
ON [dbo].[recorder_properties]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE recorder_properties
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM recorder_properties t
		INNER JOIN DELETED u ON t.meter_id = u.meter_id AND u.channel = t.channel
	END
END
GO
