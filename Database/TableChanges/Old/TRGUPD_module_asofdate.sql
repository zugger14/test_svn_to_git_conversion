SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_module_asofdate]'))
	DROP TRIGGER [dbo].[TRGUPD_module_asofdate]
GO

CREATE TRIGGER [dbo].[TRGUPD_module_asofdate]
ON [dbo].[module_asofdate]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE module_asofdate
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM module_asofdate t
		INNER JOIN DELETED u ON t.module_type = u.module_type
	END
END
GO
