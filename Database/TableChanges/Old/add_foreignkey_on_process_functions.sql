--"process_functions" table should have mapping for 'process' column with "process_control_header" table.
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_process_functions_process_control_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[process_functions]'))
BEGIN

	ALTER TABLE [dbo].[process_functions] WITH CHECK ADD CONSTRAINT [FK_process_functions_process_control_header] 
	FOREIGN KEY([process])
	REFERENCES [dbo].[process_control_header] ([process_id])

END
