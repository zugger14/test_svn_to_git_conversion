/*
Vishwas Khanal
Dated : 10.April.2009
Compliance Integration to TRM
*/

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_risk_description' AND column_name = 'requirements_id')
ALTER TABLE [dbo].[process_risk_description] ADD [requirements_id] [int] NULL

GO