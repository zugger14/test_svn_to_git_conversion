SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_program_affiliations]'))
	DROP TRIGGER [dbo].[TRGUPD_program_affiliations]
GO

CREATE TRIGGER [dbo].[TRGUPD_program_affiliations]
ON [dbo].[program_affiliations]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE program_affiliations
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM program_affiliations t
		INNER JOIN DELETED u ON t.affiliation_id = u.affiliation_id
	END
END
GO
