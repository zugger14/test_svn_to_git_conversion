/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_controls_email' and column_name = 'no_of_days')
	ALTER TABLE [dbo].[process_risk_controls_email] ADD [no_of_days] [int] NULL