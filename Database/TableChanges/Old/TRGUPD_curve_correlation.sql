SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_curve_correlation]'))
	DROP TRIGGER [dbo].[TRGUPD_curve_correlation]
GO

CREATE TRIGGER [dbo].[TRGUPD_curve_correlation]
ON [dbo].[curve_correlation]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE curve_correlation
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM curve_correlation t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
