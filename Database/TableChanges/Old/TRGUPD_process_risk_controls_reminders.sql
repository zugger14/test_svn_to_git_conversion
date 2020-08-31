SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_controls_reminders]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_controls_reminders]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_controls_reminders]
ON [dbo].[process_risk_controls_reminders]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_controls_reminders
		SET update_user = dbo.FNADBUser(),
				update_ts = GETDATE()
		FROM process_risk_controls_reminders t
		INNER JOIN DELETED u ON t.risk_control_reminder_id = u.risk_control_reminder_id
	END
END
GO
