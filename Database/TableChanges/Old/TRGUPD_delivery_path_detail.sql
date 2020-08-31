SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_delivery_path_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_delivery_path_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_delivery_path_detail]
ON [dbo].[delivery_path_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE delivery_path_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM delivery_path_detail t
		INNER JOIN DELETED u ON t.delivery_path_detail_id = u.delivery_path_detail_id
	END
END
GO
