SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_contract_charge_type_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_contract_charge_type_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_contract_charge_type_detail]
ON [dbo].[contract_charge_type_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE contract_charge_type_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM contract_charge_type_detail t
		INNER JOIN DELETED u ON t.ID = u.ID
	END
END
GO
