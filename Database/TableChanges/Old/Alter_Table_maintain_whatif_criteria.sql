IF COL_LENGTH('maintain_whatif_criteria', 'hold_to_maturity') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria 
	ADD hold_to_maturity CHAR(1)
	PRINT 'Column maintain_whatif_criteria.hold_to_maturity added.'
END
GO 

IF COL_LENGTH('maintain_whatif_criteria', 'source') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD source VARCHAR(50)
	PRINT 'Column maintain_whatif_criteria.source added.'
END
GO 

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__maintain___scena__4EA2487E]') AND parent_object_id = OBJECT_ID(N'[dbo].[maintain_whatif_criteria]'))
BEGIN
	ALTER TABLE maintain_whatif_criteria DROP CONSTRAINT FK__maintain___scena__4EA2487E
	PRINT 'Foreign key dbo.FK__maintain___scena__4EA2487E dropped'
END
GO

IF COL_LENGTH('maintain_whatif_criteria', 'scenario_id') IS NOT NULL
BEGIN
	exec sp_RENAME 'maintain_whatif_criteria.scenario_id', 'scenario_group_id' , 'COLUMN'
END 
GO 

IF COL_LENGTH('maintain_whatif_criteria', 'scenario_group_id') IS NOT NULL
BEGIN
	UPDATE maintain_whatif_criteria SET scenario_group_id = NULL
END 
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_maintain_whatif_criteria_scenario]') AND parent_object_id = OBJECT_ID(N'[dbo].[maintain_whatif_criteria]'))
BEGIN
	ALTER TABLE maintain_whatif_criteria
	ADD CONSTRAINT FK_maintain_whatif_criteria_scenario FOREIGN KEY (scenario_group_id)
		REFERENCES maintain_scenario_group (scenario_group_id) ;
	PRINT 'Foreign key FK_maintain_whatif_criteria_scenario added.'	
END
GO

ALTER TABLE maintain_whatif_criteria ALTER COLUMN active CHAR(1)
ALTER TABLE maintain_whatif_criteria ALTER COLUMN [public] CHAR(1)
ALTER TABLE maintain_whatif_criteria ALTER COLUMN hold_to_maturity CHAR(1)