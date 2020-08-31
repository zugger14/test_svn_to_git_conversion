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
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.limit_tracking ADD
	var_crit_det_id int NULL
GO
ALTER TABLE dbo.limit_tracking ADD CONSTRAINT
	FK_limit_tracking_var_measurement_criteria_detail FOREIGN KEY
	(
	var_crit_det_id
	) REFERENCES dbo.var_measurement_criteria_detail
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
