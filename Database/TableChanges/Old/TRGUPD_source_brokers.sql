SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_brokers]'))
	DROP TRIGGER [dbo].[TRGUPD_source_brokers]
GO

CREATE TRIGGER [dbo].[TRGUPD_source_brokers]
ON [dbo].[source_brokers]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE source_brokers
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM source_brokers t
		INNER JOIN DELETED u ON t.source_broker_id = u.source_broker_id
	END
END
GO
