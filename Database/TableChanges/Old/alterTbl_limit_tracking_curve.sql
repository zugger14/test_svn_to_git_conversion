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
EXECUTE sp_rename N'dbo.limit_tracking_curve.limit_value', N'Tmp_position_limit', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.limit_tracking_curve.Tmp_position_limit', N'position_limit', 'COLUMN' 
GO
ALTER TABLE dbo.limit_tracking_curve ADD
	tenor_limit float(53) NULL
GO
COMMIT
