
IF OBJECT_ID('PK__whatif_c__401F949D72DFA8F4') IS NOT NULL 
	ALTER TABLE whatif_criteria_scenario DROP CONSTRAINT PK__whatif_c__401F949D72DFA8F4

IF COL_LENGTH('whatif_criteria_scenario', 'whatif_criteria_scenario_id') IS NULL
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD whatif_criteria_scenario_id INT PRIMARY KEY IDENTITY(1,1)
	PRINT 'Column whatif_criteria_scenario.whatif_criteria_scenario_id added.'
END

IF COL_LENGTH('whatif_criteria_scenario', 'scenario_name') IS NULL 
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD scenario_name VARCHAR(100)
	PRINT 'Column whatif_criteria_scenario.scenario_name added.'
END

IF COL_LENGTH('whatif_criteria_scenario', 'scenario_description') IS NULL 
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD scenario_description VARCHAR(100)
	PRINT 'Column whatif_criteria_scenario.scenario_description added.'
END

IF COL_LENGTH('whatif_criteria_scenario', 'shift_group') IS NULL 
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD shift_group INT
	PRINT 'Column whatif_criteria_scenario.shift_group added.'
END

IF COL_LENGTH('whatif_criteria_scenario', 'shift_item') IS NULL
BEGIN
	ALTER TABLE whatif_criteria_scenario ADD shift_item INT
	PRINT 'Column whatif_criteria_scenario.shift_item added.'
END

GO

ALTER TABLE whatif_criteria_scenario ALTER COLUMN shift_by CHAR(1)