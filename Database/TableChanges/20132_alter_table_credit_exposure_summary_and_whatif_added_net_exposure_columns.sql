--credit_exposure_summary
IF COL_LENGTH('credit_exposure_summary', 'net_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD net_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'net_exposure_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'net_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD net_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'net_exposure_to_them Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'd_net_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_net_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_net_exposure_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'd_net_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_net_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_net_exposure_to_them Already Exists.'
END

--credit_exposure_summary_whatif
IF COL_LENGTH('credit_exposure_summary_whatif', 'net_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD net_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'net_exposure_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary_whatif', 'net_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD net_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'net_exposure_to_them Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary_whatif', 'd_net_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_net_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_net_exposure_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary_whatif', 'd_net_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_net_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_net_exposure_to_them Already Exists.'
END