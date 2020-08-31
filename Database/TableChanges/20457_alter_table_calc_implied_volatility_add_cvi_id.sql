IF COL_LENGTH('calc_implied_volatility', 'cvi_id') IS NULL
BEGIN
    ALTER TABLE calc_implied_volatility ADD cvi_id INT
END