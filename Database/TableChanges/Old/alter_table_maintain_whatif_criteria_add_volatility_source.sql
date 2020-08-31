IF COL_LENGTH('maintain_whatif_criteria', 'volatility_source') IS NULL
BEGIN
    ALTER TABLE maintain_whatif_criteria ADD volatility_source INT
END
GO