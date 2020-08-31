SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_pratos_source_price_curve_map]'))
	DROP TRIGGER [dbo].[TRGUPD_pratos_source_price_curve_map]
GO

CREATE TRIGGER [dbo].[TRGUPD_pratos_source_price_curve_map]
ON [dbo].[pratos_source_price_curve_map]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE pratos_source_price_curve_map
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM pratos_source_price_curve_map t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
