IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'monte_carlo_model_parameter' AND column_name = 'risk_factor')
	ALTER TABLE monte_carlo_model_parameter
		DROP COLUMN risk_factor
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'monte_carlo_model_parameter' AND column_name = 'no_of_simulation')
	ALTER TABLE monte_carlo_model_parameter
		DROP COLUMN no_of_simulation
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'monte_carlo_model_parameter' AND column_name = 'holding_days')
	ALTER TABLE monte_carlo_model_parameter
		DROP COLUMN holding_days

GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'monte_carlo_model_parameter' AND column_name = 'as_of_date_from')
	ALTER TABLE monte_carlo_model_parameter
		DROP COLUMN as_of_date_from

GO
