SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_product]'))
	DROP TRIGGER [dbo].[TRGUPD_source_product]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_product]
ON [dbo].[source_product]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_product
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_product t
		INNER JOIN DELETED u ON t.source_product_id = u.source_product_id
	END
END
GO
