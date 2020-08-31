SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_static_data_category]'))
	DROP TRIGGER [dbo].[TRGUPD_static_data_category]
GO

CREATE TRIGGER [dbo].[TRGUPD_static_data_category]
ON [dbo].[static_data_category]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE static_data_category
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM static_data_category t
		INNER JOIN DELETED u ON t.category_id = u.category_id
	END
END
GO
