IF COL_LENGTH('source_deal_settlement', 'leg') IS NULL
BEGIN
	ALTER TABLE source_deal_settlement add leg INT

	PRINT 'Column source_deal_settlement.leg added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_settlement.leg already exists.'
END
GO 
