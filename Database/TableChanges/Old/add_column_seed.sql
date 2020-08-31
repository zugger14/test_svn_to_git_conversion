IF COL_LENGTH('monte_carlo_model_parameter', 'seed') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD seed VARCHAR(100)
END
GO