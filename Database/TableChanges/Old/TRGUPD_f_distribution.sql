SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_f_distribution]'))
	DROP TRIGGER [dbo].[TRGUPD_f_distribution]
GO

CREATE TRIGGER [dbo].[TRGUPD_f_distribution]
ON [dbo].[f_distribution]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE f_distribution
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM f_distribution t
		INNER JOIN DELETED u ON t.ndf = u.ndf AND u.ddf = t.ddf AND u.alpha = t.alpha
	END
END
GO
