IF COL_LENGTH('monte_carlo_model_parameter', 'volatility_source') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD volatility_source INT
END
GO