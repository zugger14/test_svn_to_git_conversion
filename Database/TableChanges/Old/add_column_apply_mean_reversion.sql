IF COL_LENGTH('monte_carlo_model_parameter', 'apply_mean_reversion') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD apply_mean_reversion CHAR(1)
END
GO