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
				AND object_name(d.constid) = 'DF__report_me__rep_r__552C4EEA'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.report_measurement_values
	DROP CONSTRAINT DF__report_me__rep_r__552C4EEA
END 
GO

IF EXISTS (SELECT 1
			FROM sysconstraints d
			JOIN sysobjects o ON o.id = d.id
			JOIN syscolumns c ON c.id = o.id
				AND c.colid = d.colid
			WHERE d.status & 5 = 5
				AND object_name(d.constid) = 'PK_report_measurement_values1'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.report_measurement_values
	DROP CONSTRAINT PK_report_measurement_values1
END 
GO

IF COL_LENGTH('report_measurement_values', 'rep_row_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.report_measurement_values
	DROP COLUMN rep_row_id
END 
GO

COMMIT

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
				AND object_name(d.constid) = 'DF__calcproce__rep_r__71FD97C2'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.calcprocess_deals_expired
	DROP CONSTRAINT DF__calcproce__rep_r__71FD97C2
END 
GO

IF EXISTS (SELECT 1
			FROM sysconstraints d
			JOIN sysobjects o ON o.id = d.id
			JOIN syscolumns c ON c.id = o.id
				AND c.colid = d.colid
			WHERE d.status & 5 = 5
				AND object_name(d.constid) = 'PK_calcprocess_deals_expired'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.calcprocess_deals_expired
	DROP CONSTRAINT PK_calcprocess_deals_expired
END
GO

IF COL_LENGTH('calcprocess_deals_expired', 'rep_row_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.calcprocess_deals_expired
	DROP COLUMN rep_row_id
END
GO

COMMIT


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
				AND object_name(d.constid) = 'DF__report_me__rep_r__58FCDFCE'
				AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.report_measurement_values_expired
	DROP CONSTRAINT DF__report_me__rep_r__58FCDFCE
END 
GO

IF EXISTS (SELECT 1
			FROM sysconstraints d
			JOIN sysobjects o ON o.id = d.id
			JOIN syscolumns c ON c.id = o.id
			AND c.colid = d.colid
			WHERE d.status & 5 = 5
			AND object_name(d.constid) = 'PK_report_measurement_values_expired'
			AND o.xtype = 'U') 
BEGIN 
	ALTER TABLE dbo.report_measurement_values_expired
	DROP CONSTRAINT PK_report_measurement_values_expired
END 
GO


IF COL_LENGTH('report_measurement_values_expired', 'rep_row_id') IS NOT NULL
BEGIN
	ALTER TABLE dbo.report_measurement_values_expired
	DROP COLUMN rep_row_id
END 
GO

COMMIT
GO