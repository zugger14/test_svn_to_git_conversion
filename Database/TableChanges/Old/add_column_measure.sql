IF COL_LENGTH('var_measurement_criteria_detail', 'measure') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD measure INT 
END
GO
