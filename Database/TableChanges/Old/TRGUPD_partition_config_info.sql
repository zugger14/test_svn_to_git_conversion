SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_partition_config_info]'))
	DROP TRIGGER [dbo].[TRGUPD_partition_config_info]
GO

CREATE TRIGGER [dbo].[TRGUPD_partition_config_info]
ON [dbo].[partition_config_info]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE partition_config_info
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM partition_config_info t
		INNER JOIN DELETED u ON t.part_id = u.part_id
	END
END
GO
