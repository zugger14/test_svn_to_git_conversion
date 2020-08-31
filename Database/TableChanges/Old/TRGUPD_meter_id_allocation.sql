SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_meter_id_allocation]'))
	DROP TRIGGER [dbo].[TRGUPD_meter_id_allocation]
GO

CREATE TRIGGER [dbo].[TRGUPD_meter_id_allocation]
ON [dbo].[meter_id_allocation]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE meter_id_allocation
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM meter_id_allocation t
		INNER JOIN DELETED u ON t.allocation_id = u.allocation_id
	END
END
GO


