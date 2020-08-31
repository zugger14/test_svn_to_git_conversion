IF COL_LENGTH('var_measurement_criteria_detail', 'volatility_source') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD volatility_source INT
END
GO