SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_requirements_group]'))
	DROP TRIGGER [dbo].[TRGUPD_requirements_group]
GO

CREATE TRIGGER [dbo].[TRGUPD_requirements_group]
ON [dbo].[requirements_group]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE requirements_group
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM requirements_group t
		INNER JOIN DELETED u ON t.requirements_group_id = u.requirements_group_id
	END
END
GO
