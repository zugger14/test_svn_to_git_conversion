----##################
--Alter table process_risk_controls_activities
--Add [Description]
select * from process_risk_controls_activities

-----###############

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_activities' and column_name = 'Comments')
	ALTER TABLE [dbo].process_risk_controls_activities ADD Comments VARCHAR(100) NULL


ALTER TABLE process_risk_controls_activities
	Alter Column comments VARCHAR(1000)

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_activities' and column_name = 'status')
	ALTER TABLE [dbo].process_risk_controls_activities ADD status CHAR(1) NULL

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_activities' and column_name = 'source')
	ALTER TABLE [dbo].process_risk_controls_activities ADD source VARCHAR(100) NULL
