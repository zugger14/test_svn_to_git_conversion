IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_broker_fees_source_price_curve_def')
BEGIN
	--PRINT 'yo'
	ALTER TABLE broker_fees DROP CONSTRAINT FK_broker_fees_source_price_curve_def

END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_broker_fees_source_commodity')
BEGIN
	--PRINT 'yo'
	
	ALTER TABLE broker_fees DROP CONSTRAINT FK_broker_fees_source_commodity
END

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_broker_fees_source_deal_type')
BEGIN
	--PRINT 'yo'
	ALTER TABLE broker_fees DROP CONSTRAINT FK_broker_fees_source_deal_type
END
