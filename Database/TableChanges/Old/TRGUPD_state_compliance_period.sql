SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_state_compliance_period]'))
	DROP TRIGGER [dbo].[TRGUPD_state_compliance_period]
GO

CREATE TRIGGER [dbo].[TRGUPD_state_compliance_period]
ON [dbo].[state_compliance_period]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE state_compliance_period
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM state_compliance_period t
		INNER JOIN DELETED u ON t.compliance_period_id = u.compliance_period_id
	END
END
GO
