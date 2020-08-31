SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_netting_group_gain_loss]'))
	DROP TRIGGER [dbo].[TRGUPD_netting_group_gain_loss]
GO

CREATE TRIGGER [dbo].[TRGUPD_netting_group_gain_loss]
ON [dbo].[netting_group_gain_loss]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE netting_group_gain_loss
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM netting_group_gain_loss t
		INNER JOIN DELETED u ON t.netting_group_detail_id = u.netting_group_detail_id
	END
END
GO
