
IF COL_LENGTH('explain_mtm', 'market_modify_deal') IS NOT NULL
BEGIN
	EXEC sp_rename 'explain_mtm.market_modify_deal', 'market_other_modify', 'COLUMN';
	PRINT 'Column explain_mtm.market_modify_deal renamed.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.market_modify_deal IS NOT found FOR renaming.'
END
GO

IF COL_LENGTH('explain_mtm', 'contract_modify_deal') IS NOT NULL
BEGIN
	EXEC sp_rename 'explain_mtm.contract_modify_deal', 'contract_other_modify', 'COLUMN';
	PRINT 'Column explain_mtm.contract_modify_deal renamed.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.contract_modify_deal IS NOT found FOR renaming.'
END
GO

IF COL_LENGTH('explain_mtm', 'modify_deal') IS NOT NULL
BEGIN
	EXEC sp_rename 'explain_mtm.modify_deal', 'other_modify', 'COLUMN';
	PRINT 'Column explain_mtm.modify_deal renamed.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.modify_deal IS NOT found FOR renaming.'
END
GO

IF COL_LENGTH('explain_mtm', 'set_modify_deal') IS NOT NULL
BEGIN
	EXEC sp_rename 'explain_mtm.set_modify_deal', 'set_other_modify', 'COLUMN';
	PRINT 'Column explain_mtm.set_modify_deal renamed.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.set_modify_deal IS NOT found FOR renaming.'
END
GO


IF COL_LENGTH('explain_mtm', 'market_price_changed') IS NOT NULL
BEGIN
	ALTER TABLE explain_mtm DROP COLUMN market_price_changed
	PRINT 'Column explain_mtm.market_price_changed droped.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.market_price_changed IS NOT found FOR droped.'
END
GO

IF COL_LENGTH('explain_mtm', 'contract_price_changed') IS NOT NULL
BEGIN
	ALTER TABLE explain_mtm DROP COLUMN contract_price_changed
	PRINT 'Column explain_mtm.contract_price_changed droped.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.contract_price_changed IS NOT found FOR droped.'
END
GO