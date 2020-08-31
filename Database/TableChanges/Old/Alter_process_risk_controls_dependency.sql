/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_dependency' and column_name = 'risk_control_dependency_id')
	ALTER TABLE [dbo].[process_risk_controls_dependency] ADD [risk_control_dependency_id] [int] IDENTITY(1,1) NOT NULL
GO

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_dependency' and column_name = 'risk_hierarchy_level')
	ALTER TABLE [dbo].[process_risk_controls_dependency] ADD [risk_hierarchy_level] [int] NOT NULL
GO