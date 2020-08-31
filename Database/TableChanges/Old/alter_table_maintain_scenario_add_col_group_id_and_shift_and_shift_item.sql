IF COL_LENGTH('maintain_scenario', 'scenario_group_id') IS NULL
BEGIN
	ALTER TABLE maintain_scenario ADD scenario_group_id INT REFERENCES maintain_scenario_group(scenario_group_id)
	PRINT 'Column maintain_scenario.scenario_group_id added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_scenario.scenario_group_id already exists.'
END

IF COL_LENGTH('maintain_scenario', 'shift_group') IS NULL
BEGIN
	ALTER TABLE maintain_scenario ADD shift_group INT
	PRINT 'Column maintain_scenario.shift_group added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_scenario.shift_group already exists.'
END

IF COL_LENGTH('maintain_scenario', 'shift_item') IS NULL
BEGIN
	ALTER TABLE maintain_scenario ADD shift_item INT
	PRINT 'Column maintain_scenario.shift_item added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_scenario.shift_item already exists.'
END