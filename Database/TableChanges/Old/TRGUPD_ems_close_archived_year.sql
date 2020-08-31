SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_close_archived_year]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_close_archived_year]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_close_archived_year]
ON [dbo].[ems_close_archived_year]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_close_archived_year
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_close_archived_year t
		INNER JOIN DELETED u ON t.as_of_date = u.as_of_date
	END
END
GO
