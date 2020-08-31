IF COL_LENGTH('maintain_whatif_criteria', 'scenario_type') IS NULL
BEGIN
    ALTER TABLE maintain_whatif_criteria ADD scenario_type CHAR(1)
END
GO