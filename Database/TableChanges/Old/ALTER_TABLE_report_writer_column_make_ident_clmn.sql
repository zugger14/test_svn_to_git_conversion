
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.report_writer_column
	DROP CONSTRAINT FK_report_writer_column_Report_record
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_report_writer_column
	(
	report_column_id int NOT NULL IDENTITY (1, 1),
	report_id int NOT NULL,
	column_id int NOT NULL,
	column_selected varchar(50) NULL,
	column_name varchar(250) NULL,
	columns varchar(250) NULL,
	column_alias varchar(250) NULL,
	filter_column varchar(50) NULL,
	max varchar(50) NULL,
	min varchar(50) NULL,
	count varchar(50) NULL,
	sum varchar(50) NULL,
	average varchar(50) NULL,
	create_user varchar(100) NULL,
	create_ts datetime NULL,
	update_user varchar(100) NULL,
	update_ts datetime NULL,
	user_define char(1) NULL,
	data_type varchar(50) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_report_writer_column ADD CONSTRAINT
	DF_report_writer_column_create_user DEFAULT dbo.FNADBUser() FOR create_user
GO
ALTER TABLE dbo.Tmp_report_writer_column ADD CONSTRAINT
	DF_report_writer_column_create_ts DEFAULT GETDATE() FOR create_ts
GO

IF EXISTS(SELECT * FROM dbo.report_writer_column)
	 EXEC('INSERT INTO dbo.Tmp_report_writer_column (report_id, column_id, column_selected, column_name, columns, column_alias, filter_column, max, min, count, sum, average, create_user, create_ts, update_user, update_ts, user_define, data_type)
		SELECT report_id, column_id, column_selected, column_name, columns, column_alias, filter_column, max, min, count, sum, average, create_user, create_ts, update_user, update_ts, user_define, data_type FROM dbo.report_writer_column WITH (HOLDLOCK TABLOCKX)')
GO

DROP TABLE dbo.report_writer_column
GO
EXECUTE sp_rename N'dbo.Tmp_report_writer_column', N'report_writer_column', 'OBJECT' 
GO
ALTER TABLE dbo.report_writer_column ADD CONSTRAINT
	PK_report_writer_column PRIMARY KEY CLUSTERED 
	(
	report_column_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.report_writer_column ADD CONSTRAINT
	IX_report_writer_column UNIQUE NONCLUSTERED 
	(
	report_id,
	column_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.report_writer_column ADD CONSTRAINT
	FK_report_writer_column_Report_record FOREIGN KEY
	(
	report_id
	) REFERENCES dbo.Report_record
	(
	report_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT
