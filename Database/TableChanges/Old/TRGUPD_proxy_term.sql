SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_proxy_term]'))
	DROP TRIGGER [dbo].[TRGUPD_proxy_term]
GO

CREATE TRIGGER [dbo].[TRGUPD_proxy_term]
ON [dbo].[proxy_term]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE proxy_term
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM proxy_term t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO



