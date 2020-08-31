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
IF EXISTS (SELECT 1
			FROM sysconstraints d
			JOIN sysobjects o ON o.id = d.id
			JOIN syscolumns c ON c.id = o.id
				AND c.colid = d.colid
			WHERE d.status & 5 = 5
				AND object_name(d.constid) = 'DF__source_de__rep_r__7E2F2FD4'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.source_deal_pnl_arch2
	DROP CONSTRAINT DF__source_de__rep_r__7E2F2FD4
END 
GO

IF EXISTS (SELECT 1
			FROM sysconstraints d
			JOIN sysobjects o ON o.id = d.id
			JOIN syscolumns c ON c.id = o.id
				AND c.colid = d.colid
			WHERE d.status & 5 = 5
				AND object_name(d.constid) = 'PK_source_deal_pnl_arch2'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.source_deal_pnl_arch2
	DROP CONSTRAINT PK_source_deal_pnl_arch2
END 
GO

IF COL_LENGTH('source_deal_pnl_arch2', 'rep_row_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.source_deal_pnl_arch2
	DROP COLUMN rep_row_id
END
GO

COMMIT
GO