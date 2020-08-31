SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_company_info]'))
	DROP TRIGGER [dbo].[TRGUPD_company_info]
GO

CREATE TRIGGER [dbo].[TRGUPD_company_info]
ON [dbo].[company_info]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE company_info
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM company_info t
		INNER JOIN DELETED u ON t.company_id = u.company_id
	END
END
GO
