SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_netting_group_detail_contract]'))
	DROP TRIGGER [dbo].[TRGUPD_netting_group_detail_contract]
GO

CREATE TRIGGER [dbo].[TRGUPD_netting_group_detail_contract]
ON [dbo].[netting_group_detail_contract]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE netting_group_detail_contract
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM netting_group_detail_contract t
		INNER JOIN DELETED u ON t.netting_contract_id = u.netting_contract_id
	END
END
GO
