IF COL_LENGTH('monte_carlo_model_parameter', 'relative_volatility') IS NULL
BEGIN
	ALTER TABLE monte_carlo_model_parameter
	ADD relative_volatility CHAR(1)
	PRINT 'Column monte_carlo_model_parameter.relative_volatility added.'
END
GO 