IF COL_LENGTH('monte_carlo_model_parameter', 'volatility_method') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD volatility_method CHAR(1)
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_data_series') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_data_series INT
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_data_points') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_data_points INT
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_long_run_volatility') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_long_run_volatility FLOAT
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_alpha') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_alpha FLOAT
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_beta') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_beta FLOAT
END
GO
IF COL_LENGTH('monte_carlo_model_parameter', 'vol_gamma') IS NULL
BEGIN
    ALTER TABLE monte_carlo_model_parameter ADD vol_gamma FLOAT
END
GO