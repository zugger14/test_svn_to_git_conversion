IF COL_LENGTH('credit_exposure_detail', 'internal_counterparty_id') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD internal_counterparty_id INT
END
ELSE
BEGIN
	PRINT 'Column internal_counterparty_id EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'contract_id') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD contract_id INT
END
ELSE
BEGIN
	PRINT 'Column contract_id EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'gross_exposure_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD gross_exposure_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column gross_exposure_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_gross_exposure_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_gross_exposure_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_gross_exposure_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'net_exposure_to_us_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD net_exposure_to_us_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column net_exposure_to_us_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'net_exposure_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD net_exposure_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column net_exposure_to_them_round EXISTS'
END



IF COL_LENGTH('credit_exposure_detail', 'total_net_exposure_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD total_net_exposure_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column total_net_exposure_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'limit_to_us_avail_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_us_avail_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_us_avail_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_to_them_avail_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_them_avail_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_them_avail_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'limit_to_us_violated_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_us_violated_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_us_violated_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_to_them_violated_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_them_violated_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_them_violated_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'tenor_limit_violated_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD tenor_limit_violated_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column tenor_limit_violated_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'limit_to_us_variance_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_us_variance_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_us_variance_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_to_them_variance_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_to_them_variance_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_to_them_variance_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_net_exposure_to_us_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_net_exposure_to_us_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_net_exposure_to_us_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_net_exposure_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_net_exposure_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_net_exposure_to_them_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_total_net_exposure_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_total_net_exposure_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_total_net_exposure_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_limit_to_us_avail_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_limit_to_us_avail_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_limit_to_us_avail_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_limit_to_them_avail_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_limit_to_them_avail_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_limit_to_them_avail_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_limit_to_us_variance_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_limit_to_us_variance_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_limit_to_us_variance_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_limit_to_them_variance_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_limit_to_them_variance_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_limit_to_them_variance_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'gross_exposure_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD gross_exposure_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column gross_exposure_to_them_round EXISTS'
END