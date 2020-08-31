/*
   Thursday, April 02, 200910:00:59 AM
   User: farrms_admin
   Server: MSINGH\INSTANCE1
   Database: TRMTracker
   Rename fomulaId with formulaId
*/

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
EXECUTE sp_rename N'dbo.system_formula.fomulaId', N'Tmp_formulaId', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.system_formula.Tmp_formulaId', N'formulaId', 'COLUMN' 
GO
COMMIT
