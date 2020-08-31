
IF COL_LENGTH('source_deal_header', 'fx_rounding') IS NULL
BEGIN
	alter table source_deal_header add fx_rounding	int
END

IF COL_LENGTH('source_deal_header', 'fx_option') IS NULL
BEGIN
	alter table source_deal_header add fx_option	int
END



