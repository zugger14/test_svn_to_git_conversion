SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_var_time_bucket_mapping]'))
	DROP TRIGGER [dbo].[TRGUPD_var_time_bucket_mapping]
GO

CREATE TRIGGER [dbo].[TRGUPD_var_time_bucket_mapping]
ON [dbo].[var_time_bucket_mapping]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE var_time_bucket_mapping
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM var_time_bucket_mapping t
		INNER JOIN DELETED u ON t.map_id = u.map_id
	END
END
GO
