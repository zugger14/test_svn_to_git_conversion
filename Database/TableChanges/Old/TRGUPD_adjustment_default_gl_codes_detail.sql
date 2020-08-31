SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_adjustment_default_gl_codes_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_adjustment_default_gl_codes_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_adjustment_default_gl_codes_detail]
ON [dbo].[adjustment_default_gl_codes_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE adjustment_default_gl_codes_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM adjustment_default_gl_codes_detail t
		INNER JOIN DELETED u ON t.detail_id = u.detail_id
	END
END
GO

