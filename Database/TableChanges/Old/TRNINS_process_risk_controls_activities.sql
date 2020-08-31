
/*
Author :  Vishwas Khanal
Dated : 02.15.2010
*/
IF OBJECT_ID('TRGINS_PROCESS_RISK_CONTROLS_ACTIVITIES','TR') IS NOT NULL
DROP TRIGGER TRGINS_PROCESS_RISK_CONTROLS_ACTIVITIES
GO
CREATE TRIGGER [TRGINS_PROCESS_RISK_CONTROLS_ACTIVITIES]
ON [dbo].[process_risk_controls_activities]
FOR INSERT
AS
UPDATE process_risk_controls_activities SET create_user = dbo.FNADBUser(), create_ts = GETDATE() WHERE  risk_control_activity_id in (SELECT risk_control_activity_id FROM inserted)

