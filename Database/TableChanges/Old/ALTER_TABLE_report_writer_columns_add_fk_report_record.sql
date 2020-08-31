GO
IF OBJECT_ID(N'FK_report_writer_column_Report_record', N'F') IS NULL
BEGIN
	ALTER TABLE dbo.report_writer_column ADD CONSTRAINT
	FK_report_writer_column_Report_record FOREIGN KEY
	(
	report_id
	) REFERENCES dbo.Report_record
	(
	report_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
END

GO
