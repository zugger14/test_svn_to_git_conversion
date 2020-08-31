SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_expected_return]'))
	DROP TRIGGER [dbo].[TRGUPD_expected_return]
GO

CREATE TRIGGER [dbo].[TRGUPD_expected_return]
ON [dbo].[expected_return]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE expected_return
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM expected_return t
		INNER JOIN DELETED u ON t.expected_return_id = u.expected_return_id
	END
END
GO
