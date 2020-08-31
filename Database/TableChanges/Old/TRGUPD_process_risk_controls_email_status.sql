SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_controls_email_status]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_controls_email_status]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_controls_email_status]
ON [dbo].[process_risk_controls_email_status]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_controls_email_status
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_risk_controls_email_status t
		INNER JOIN DELETED u ON t.risk_control_email_status_id = u.risk_control_email_status_id
	END
END
GO
