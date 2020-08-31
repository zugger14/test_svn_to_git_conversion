IF COL_LENGTH('curve_volatility_imp', 'strike') IS NULL
BEGIN
    ALTER TABLE curve_volatility_imp ADD strike FLOAT
END