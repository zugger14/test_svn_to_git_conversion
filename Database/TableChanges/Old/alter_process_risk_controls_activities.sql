BEGIN TRAN 
IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE WHERE 
	table_name = 'process_risk_controls_activities_audit' AND constraint_name = 'FK_process_risk_controls_activities_audit_process_risk_controls_activities')
	ALTER TABLE dbo.process_risk_controls_activities_audit DROP CONSTRAINT FK_process_risk_controls_activities_audit_process_risk_controls_activities

DELETE FROM dbo.process_risk_controls_activities_audit

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE 
	table_name = 'process_risk_controls_activities_audit' AND column_name = 'risk_control_activity_id')
	ALTER TABLE dbo.process_risk_controls_activities_audit ADD risk_control_activity_id INT NOT NULL CONSTRAINT[FK_process_risk_controls_activities_risk_control_activity_id] FOREIGN KEY REFERENCES dbo.process_risk_controls_activities(risk_control_activity_id)
	
IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE WHERE table_name = 'process_risk_controls_activities' AND constraint_name = 'IX_process_risk_controls_activities')
	ALTER TABLE dbo.process_risk_controls_activities DROP CONSTRAINT IX_process_risk_controls_activities


commit 

--process_risk_controls_activities
--process_risk_controls_activities_audit

--SELECT * FROM INFORMATION_SCHEMA.COLUMNS


