SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_inventory_account_type_group]'))
	DROP TRIGGER [dbo].[TRGUPD_inventory_account_type_group]
GO

CREATE TRIGGER [dbo].[TRGUPD_inventory_account_type_group]
ON [dbo].[inventory_account_type_group]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE inventory_account_type_group
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM inventory_account_type_group t
		INNER JOIN DELETED u ON t.group_id = u.group_id
	END
END
GO
