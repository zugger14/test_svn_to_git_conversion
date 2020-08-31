SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_virtual_storage_constraint]'))
	DROP TRIGGER [dbo].[TRGUPD_virtual_storage_constraint]
GO

CREATE TRIGGER [dbo].[TRGUPD_virtual_storage_constraint]
ON [dbo].[virtual_storage_constraint]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE virtual_storage_constraint
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM virtual_storage_constraint t
		INNER JOIN DELETED u ON t.constraint_id = u.constraint_id
	END
END
GO
