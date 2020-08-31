/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
--IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_main' and column_name = 'standard_revision_id')
--BEGIN
--	ALTER TABLE [dbo].[process_requirements_main] ADD [standard_revision_id] [int] NOT NULL
--
--	ALTER TABLE [dbo].[process_requirements_main]  WITH NOCHECK ADD  CONSTRAINT 
--	[FK_process_requirements_main_process_standard_main] FOREIGN KEY([standard_revision_id])
--	REFERENCES [dbo].[process_standard_revisions] ([standard_revision_id])
--END
--GO

IF EXISTS ( SELECT 'X' FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE  WHERE TABLE_NAME = 'process_requirements_main'
 AND CONSTRAINT_NAME = 'FK_process_requirements_main_process_standard_main')
	ALTER TABLE dbo.process_requirements_main DROP CONSTRAINT FK_process_requirements_main_process_standard_main
GO 

IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_main' and column_name = 'standard_id')
	ALTER TABLE dbo.process_requirements_main DROP COLUMN standard_id 
GO 

IF EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'process_requirements_main' and column_name = 'standard_revision_id')
	ALTER TABLE dbo.process_requirements_main DROP COLUMN standard_revision_id


GO	
	ALTER TABLE dbo.process_requirements_main ADD standard_revision_id INT NOT NULL 

	ALTER TABLE [dbo].[process_requirements_main]  WITH NOCHECK ADD  CONSTRAINT 
	[FK_process_requirements_main_process_standard_main] FOREIGN KEY([standard_revision_id])
	REFERENCES [dbo].[process_standard_revisions] ([standard_revision_id])

