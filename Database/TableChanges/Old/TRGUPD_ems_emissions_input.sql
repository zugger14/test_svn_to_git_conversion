
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_emissions_input]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_emissions_input]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_emissions_input]
ON [dbo].[ems_emissions_input]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_emissions_input
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_emissions_input t
		INNER JOIN DELETED u ON t.ID = u.ID
	END
END
GO
