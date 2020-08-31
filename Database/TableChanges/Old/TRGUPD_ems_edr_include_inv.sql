SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_edr_include_inv]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_edr_include_inv]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_edr_include_inv]
ON [dbo].[ems_edr_include_inv]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_edr_include_inv
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_edr_include_inv t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
