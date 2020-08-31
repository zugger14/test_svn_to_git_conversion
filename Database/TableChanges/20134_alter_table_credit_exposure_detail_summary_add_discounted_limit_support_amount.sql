IF COL_LENGTH('credit_exposure_detail', 'd_counterparty_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_counterparty_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_counterparty_credit_support_amt Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail', 'd_internal_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_internal_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_internal_credit_support_amt Already Exists.'
END


IF COL_LENGTH('credit_exposure_detail', 'd_limit_available_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_limit_available_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail', 'd_limit_available_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail ADD d_limit_available_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_them Already Exists.'
END


IF COL_LENGTH('credit_exposure_summary', 'd_counterparty_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_counterparty_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_counterparty_credit_support_amt Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'd_internal_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_internal_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_internal_credit_support_amt Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'd_limit_available_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_limit_available_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary', 'd_limit_available_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary ADD d_limit_available_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_them Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail_whatif', 'd_counterparty_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail_whatif ADD d_counterparty_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_counterparty_credit_support_amt Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail_whatif', 'd_internal_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail_whatif ADD d_internal_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_internal_credit_support_amt Already Exists.'
END


IF COL_LENGTH('credit_exposure_detail_whatif', 'd_limit_available_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail_whatif ADD d_limit_available_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_detail_whatif', 'd_limit_available_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_detail_whatif ADD d_limit_available_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_them Already Exists.'
END


IF COL_LENGTH('credit_exposure_summary_whatif', 'd_counterparty_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_counterparty_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_counterparty_credit_support_amt Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary_whatif', 'd_internal_credit_support_amt') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_internal_credit_support_amt FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_internal_credit_support_amt Already Exists.'
END


IF COL_LENGTH('credit_exposure_summary_whatif', 'd_limit_available_to_us') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_limit_available_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_us Already Exists.'
END

IF COL_LENGTH('credit_exposure_summary_whatif', 'd_limit_available_to_them') IS NULL
BEGIN
    ALTER TABLE credit_exposure_summary_whatif ADD d_limit_available_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_limit_available_to_them Already Exists.'
END