SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_power_bidding_nomination_mapping]'))
	DROP TRIGGER [dbo].[TRGUPD_power_bidding_nomination_mapping]
GO

CREATE TRIGGER [dbo].[TRGUPD_power_bidding_nomination_mapping]
ON [dbo].[power_bidding_nomination_mapping]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE power_bidding_nomination_mapping
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM power_bidding_nomination_mapping t
		INNER JOIN DELETED u ON t.power_bidding_nomination_mapping_id = u.power_bidding_nomination_mapping_id
	END
END
GO
