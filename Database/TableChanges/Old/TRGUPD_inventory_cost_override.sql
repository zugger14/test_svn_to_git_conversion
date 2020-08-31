SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_inventory_cost_override]'))
	DROP TRIGGER [dbo].[TRGUPD_inventory_cost_override]
GO

CREATE TRIGGER [dbo].[TRGUPD_inventory_cost_override]
ON [dbo].[inventory_cost_override]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE inventory_cost_override
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM inventory_cost_override t
		INNER JOIN DELETED u ON t.inventory_cost_id = u.inventory_cost_id
	END
END
GO
