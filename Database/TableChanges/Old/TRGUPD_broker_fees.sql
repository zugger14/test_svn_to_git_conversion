SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_broker_fees]'))
	DROP TRIGGER [dbo].[TRGUPD_broker_fees]
GO

CREATE TRIGGER [dbo].[TRGUPD_broker_fees]
ON [dbo].[broker_fees]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE broker_fees
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM broker_fees t
		INNER JOIN DELETED u ON t.broker_fees_id = u.broker_fees_id
	END
END
GO

