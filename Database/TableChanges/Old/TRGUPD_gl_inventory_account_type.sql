SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_gl_inventory_account_type]'))
	DROP TRIGGER [dbo].[TRGUPD_gl_inventory_account_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_gl_inventory_account_type]
ON [dbo].[gl_inventory_account_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE gl_inventory_account_type
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM gl_inventory_account_type t
		INNER JOIN DELETED u ON t.gl_account_id = u.gl_account_id
	END
END
GO
