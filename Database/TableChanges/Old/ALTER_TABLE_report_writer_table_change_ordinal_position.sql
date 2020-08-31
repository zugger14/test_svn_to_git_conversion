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
CREATE TABLE dbo.Tmp_report_writer_table
	(
	id int NOT NULL IDENTITY (1, 1),
	table_name varchar(50) NOT NULL,
	table_alias varchar(50) NOT NULL,
	table_description varchar(250) NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL,
	vw_sql varchar(MAX) NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_report_writer_table ON
GO
IF EXISTS(SELECT * FROM dbo.report_writer_table)
	 EXEC('INSERT INTO dbo.Tmp_report_writer_table (id, table_name, table_alias, table_description, create_user, create_ts, update_user, update_ts, vw_sql)
		SELECT id, table_name, table_alias, table_description, create_user, create_ts, update_user, update_ts, vw_sql FROM dbo.report_writer_table WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_report_writer_table OFF
GO
ALTER TABLE dbo.report_layout
	DROP CONSTRAINT FK_report_layout_report_writer_table
GO
DROP TABLE dbo.report_writer_table
GO
EXECUTE sp_rename N'dbo.Tmp_report_writer_table', N'report_writer_table', 'OBJECT' 
GO
ALTER TABLE dbo.report_writer_table ADD CONSTRAINT
	PK_report_writer_table_1 PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.report_writer_table ADD CONSTRAINT
	IX_report_writer_table UNIQUE NONCLUSTERED 
	(
	table_name
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE TRIGGER TRGINS_REPORT_WRITER_TABLE
ON dbo.report_writer_table
FOR INSERT
AS
UPDATE DBO.REPORT_WRITER_TABLE SET create_user = dbo.FNADBUser(), create_ts = getdate() where  REPORT_WRITER_TABLE.table_name in (select table_name from inserted)
GO
CREATE TRIGGER [dbo].[TRGUPD_REPORT_WRITER_TABLE]
ON dbo.report_writer_table
FOR UPDATE
AS

IF NOT UPDATE(create_user) AND NOT UPDATE(create_ts)
	UPDATE DBO.REPORT_WRITER_TABLE SET update_user = dbo.FNADBUser(), update_ts = getdate() where  REPORT_WRITER_TABLE.table_name in (select table_name from deleted)
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
