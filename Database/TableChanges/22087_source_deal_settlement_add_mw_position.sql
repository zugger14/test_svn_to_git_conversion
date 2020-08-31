IF COL_LENGTH('source_deal_settlement', 'mw_position') IS NULL
BEGIN
	alter table source_deal_settlement add mw_position float
END
ELSE
BEGIN
	PRINT 'Column mw_position EXISTS'
END


IF COL_LENGTH('source_deal_settlement_tou', 'mw_position') IS NULL
BEGIN
	alter table source_deal_settlement_tou add mw_position float
END
ELSE
BEGIN
	PRINT 'Column mw_position EXISTS'
END



