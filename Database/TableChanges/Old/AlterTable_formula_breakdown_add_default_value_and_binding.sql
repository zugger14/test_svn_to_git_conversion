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

IF EXISTS(
	SELECT 1 FROM sysobjects so 
	JOIN sysconstraints sc ON so.id = sc.constid 
	WHERE object_name(so.parent_obj) = 'formula_breakdown'
		AND so.xtype = 'D'
		AND sc.colid = (
					SELECT colid FROM syscolumns 
					WHERE id = object_id('dbo.formula_breakdown') 
					AND name = 'create_user'
		)
)
BEGIN
	ALTER TABLE dbo.formula_breakdown DROP CONSTRAINT DF_formula_breakdown_create_user
END

ALTER TABLE dbo.formula_breakdown ADD CONSTRAINT
DF_formula_breakdown_create_user DEFAULT([dbo].[FNADBUser]()) FOR create_user

GO

IF EXISTS(
	SELECT 1 FROM sysobjects so 
	JOIN sysconstraints sc ON so.id = sc.constid 
	WHERE object_name(so.parent_obj) = 'formula_breakdown'
		AND so.xtype = 'D'
		AND sc.colid = (
					SELECT colid FROM syscolumns 
					WHERE id = object_id('dbo.formula_breakdown') 
					AND name = 'create_ts'
		)
)
BEGIN
	ALTER TABLE dbo.formula_breakdown DROP CONSTRAINT DF_formula_breakdown_create_ts
END

ALTER TABLE dbo.formula_breakdown ADD CONSTRAINT
DF_formula_breakdown_create_ts DEFAULT(GETDATE()) FOR create_ts

GO

ALTER TABLE dbo.formula_breakdown 
SET (LOCK_ESCALATION = TABLE)
GO

COMMIT




