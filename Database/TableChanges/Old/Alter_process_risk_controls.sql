/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls' and column_name = 'perform_activity')
	ALTER TABLE [dbo].[process_risk_controls] ADD [perform_activity] [int] NULL

alter table process_risk_controls alter column monetary_value Float
GO