SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_controls_reminders_acknowledge]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_controls_reminders_acknowledge]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_controls_reminders_acknowledge]
ON [dbo].[process_risk_controls_reminders_acknowledge]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_controls_reminders_acknowledge
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM process_risk_controls_reminders_acknowledge t
		INNER JOIN DELETED u ON t.reminder_acknowledge_id = u.reminder_acknowledge_id
	END
END
GO
