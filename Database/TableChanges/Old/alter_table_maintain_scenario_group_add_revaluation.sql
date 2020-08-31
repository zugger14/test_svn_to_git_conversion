IF COL_LENGTH('maintain_scenario_group', 'revaluation') IS NULL
BEGIN
    ALTER TABLE maintain_scenario_group ADD revaluation CHAR(1)
END
GO