SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_factor]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_factor]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_factor]
ON [dbo].[ems_factor]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_factor
		SET update_user = dbo.FNADBUser(),
			update_ts  = GETDATE()
		FROM ems_factor t
		INNER JOIN DELETED u ON t.ems_factor_id = u.ems_factor_id
	END
END
GO
