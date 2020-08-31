SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_contract_charge_type]'))
	DROP TRIGGER [dbo].[TRGUPD_contract_charge_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_contract_charge_type]
ON [dbo].[contract_charge_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE contract_charge_type
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM contract_charge_type t
		INNER JOIN DELETED u ON t.contract_charge_type_id = u.contract_charge_type_id
	END
END
GO
