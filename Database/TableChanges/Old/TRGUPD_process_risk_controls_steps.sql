SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_risk_controls_steps]'))
	DROP TRIGGER [dbo].[TRGUPD_process_risk_controls_steps]
GO

CREATE TRIGGER [dbo].[TRGUPD_process_risk_controls_steps]
ON [dbo].[process_risk_controls_steps]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE process_risk_controls_steps
		SET update_user = dbo.FNADBUser(),
				update_ts = GETDATE()
		FROM process_risk_controls_steps t
		INNER JOIN DELETED u ON t.risk_control_step_id = u.risk_control_step_id
	END
END
GO
