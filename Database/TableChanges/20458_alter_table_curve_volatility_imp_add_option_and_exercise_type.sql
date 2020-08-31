IF COL_LENGTH('curve_volatility_imp', 'option_type') IS NULL
BEGIN
    ALTER TABLE curve_volatility_imp ADD option_type CHAR(1)
END
IF COL_LENGTH('curve_volatility_imp', 'exercise_type') IS NULL
BEGIN
    ALTER TABLE curve_volatility_imp ADD exercise_type CHAR(1)
END