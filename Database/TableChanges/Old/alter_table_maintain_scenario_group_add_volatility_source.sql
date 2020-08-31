IF COL_LENGTH('maintain_scenario_group', 'volatility_source') IS NULL
BEGIN
    ALTER TABLE maintain_scenario_group ADD volatility_source INT
END
GO