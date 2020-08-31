IF COL_LENGTH('credit_exposure_summary_whatif', 'currency_name') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD currency_name VARCHAR(20)
END
ELSE
BEGIN
    PRINT 'currency_name Already Exists.'
END