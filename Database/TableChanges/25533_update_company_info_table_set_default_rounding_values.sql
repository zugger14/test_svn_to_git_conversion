IF COL_LENGTH('company_info', 'price_rounding') IS NOT NULL
BEGIN
	UPDATE company_info
	SET price_rounding = 4
END

IF COL_LENGTH('company_info', 'volume_rounding') IS NOT NULL
BEGIN
	UPDATE company_info
	SET volume_rounding = 2
END

IF COL_LENGTH('company_info', 'amount_rounding') IS NOT NULL
BEGIN
	UPDATE company_info
	SET amount_rounding = 2
END

IF COL_LENGTH('company_info', 'number_rounding') IS NOT NULL
BEGIN
	UPDATE company_info
	SET number_rounding = 4
END