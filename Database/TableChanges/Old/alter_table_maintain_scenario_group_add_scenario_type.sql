IF COL_LENGTH('maintain_scenario_group', 'scenario_type') IS NULL
BEGIN
    ALTER TABLE maintain_scenario_group ADD scenario_type CHAR(1)
END
GO