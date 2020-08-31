IF COL_LENGTH('maintain_whatif_criteria', 'revaluation') IS NULL
BEGIN
    ALTER TABLE maintain_whatif_criteria ADD revaluation CHAR(1)
END
GO