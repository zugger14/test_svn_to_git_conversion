IF COL_LENGTH('credit_exposure_detail', 'buy_sell_flag') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD buy_sell_flag CHAR(1)
END
ELSE
BEGIN
	PRINT 'Column buy_sell_flag EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'commodity_id') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD commodity_id INT
END
ELSE
BEGIN
	PRINT 'Column commodity_id EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'physical_financial_flag') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD physical_financial_flag CHAR(1)
END
ELSE
BEGIN
	PRINT 'Column physical_financial_flag EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'payment_date') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD payment_date DATE
END
ELSE
BEGIN
	PRINT 'Column payment_date EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'trader_id') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD trader_id INT
END
ELSE
BEGIN
	PRINT 'Column trader_id EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'apply_netting_rule') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD apply_netting_rule CHAR(1)
END
ELSE
BEGIN
	PRINT 'Column apply_netting_rule EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'ar_prior') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD ar_prior FLOAT
END
ELSE
BEGIN
	PRINT 'Column ar_prior EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'ar_current') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD ar_current FLOAT
END
ELSE
BEGIN
	PRINT 'Column ar_current EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'ap_prior') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD ap_prior FLOAT
END
ELSE
BEGIN
	PRINT 'Column ap_prior EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'ap_current') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD ap_current FLOAT
END
ELSE
BEGIN
	PRINT 'Column ap_current EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'bom_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD bom_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column bom_exposure_to_us EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'bom_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD bom_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column bom_exposure_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_bom_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_bom_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_bom_exposure_to_us EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_bom_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_bom_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_bom_exposure_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'mtm_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD mtm_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column mtm_exposure_to_us EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'mtm_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD mtm_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column mtm_exposure_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_mtm_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_mtm_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_mtm_exposure_to_us EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_mtm_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_mtm_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_mtm_exposure_to_them EXISTS'
END		

IF COL_LENGTH('credit_exposure_detail', 'exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column exposure_to_us EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column exposure_to_them EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'total_exposure_to_us_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD total_exposure_to_us_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column total_exposure_to_us_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'total_exposure_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD total_exposure_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column total_exposure_to_them_round EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'd_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_exposure_to_us EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'd_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD d_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column d_exposure_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'effective_exposure_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD effective_exposure_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column effective_exposure_to_us EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'effective_exposure_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD effective_exposure_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column effective_exposure_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'effective_exposure_to_us_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD effective_exposure_to_us_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column effective_exposure_to_us_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'effective_exposure_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD effective_exposure_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column effective_exposure_to_them_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'collateral_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD collateral_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column collateral_received EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'collateral_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD collateral_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column collateral_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'cash_collateral_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD cash_collateral_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column cash_collateral_received EXISTS'
END	

IF COL_LENGTH('credit_exposure_detail', 'cash_collateral_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD cash_collateral_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column cash_collateral_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'colletral_not_used_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD colletral_not_used_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column colletral_not_used_received EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'colletral_not_used_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD colletral_not_used_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column colletral_not_used_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'prepay_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD prepay_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column prepay_received EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'prepay_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD prepay_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column prepay_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_received EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_available_to_us') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_available_to_us FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_available_to_us EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_available_to_them') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_available_to_them FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_available_to_them EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_available_to_us_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_available_to_us_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_available_to_us_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'limit_available_to_them_round') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD limit_available_to_them_round FLOAT
END
ELSE
BEGIN
	PRINT 'Column limit_available_to_them_round EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'rounding') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD rounding FLOAT
END
ELSE
BEGIN
	PRINT 'Column rounding EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'threshold_provided') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD threshold_provided FLOAT
END
ELSE
BEGIN
	PRINT 'Column threshold_provided EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'threshold_received') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD threshold_received FLOAT
END
ELSE
BEGIN
	PRINT 'Column threshold_received EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'counterparty_credit_support_amount') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD counterparty_credit_support_amount FLOAT
END
ELSE
BEGIN
	PRINT 'Column counterparty_credit_support_amount EXISTS'
END

IF COL_LENGTH('credit_exposure_detail', 'internal_credit_support_amount') IS NULL
BEGIN
ALTER TABLE credit_exposure_detail ADD internal_credit_support_amount FLOAT
END
ELSE
BEGIN
	PRINT 'Column internal_credit_support_amount EXISTS'
END