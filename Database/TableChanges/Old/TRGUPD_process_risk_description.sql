SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_description]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_description]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_description]
ON [dbo].[process_risk_description]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_description
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_risk_description t
		INNER JOIN DELETED u ON t.risk_description_id = u.risk_description_id
	END
END
GO

