/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/


IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_assignment' and column_name = 'requirements_revision_id')
	ALTER TABLE [dbo].[process_requirements_assignment] ADD [requirements_revision_id] [int] NULL
GO

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_assignment' and column_name = 'run_date')
	ALTER TABLE [dbo].[process_requirements_assignment] ADD [run_date] [datetime] NULL
GO