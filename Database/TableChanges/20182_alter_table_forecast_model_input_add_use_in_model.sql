IF COL_LENGTH('forecast_model_input', 'use_in_model') IS NULL
BEGIN
    ALTER TABLE forecast_model_input ADD use_in_model INT
END
GO


IF COL_LENGTH('forecast_model_input', 's_order') IS NULL
BEGIN
    ALTER TABLE forecast_model_input ADD s_order INT
END
GO


IF COL_LENGTH('forecast_model_input', 'output_series') IS NULL
BEGIN
    ALTER TABLE forecast_model_input ADD output_series INT
END
GO


