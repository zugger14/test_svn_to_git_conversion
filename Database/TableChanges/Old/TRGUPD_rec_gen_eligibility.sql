SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rec_gen_eligibility]'))
	DROP TRIGGER [dbo].[TRGUPD_rec_gen_eligibility]
GO

CREATE TRIGGER [dbo].[TRGUPD_rec_gen_eligibility]
ON [dbo].[rec_gen_eligibility]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE rec_gen_eligibility
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM rec_gen_eligibility t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
