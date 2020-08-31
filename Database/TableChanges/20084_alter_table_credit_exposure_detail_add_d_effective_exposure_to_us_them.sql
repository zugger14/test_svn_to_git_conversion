IF COL_LENGTH('credit_exposure_detail', 'd_effective_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_effective_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail', 'd_effective_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_effective_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_them Already Exists.'
END