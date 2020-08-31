SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2177)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2177, 2175, 'source_deal_pnl_detail', 'Source Deal Pnl Detail(MTM)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2177 - source_deal_pnl_detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 2177 - source_deal_pnl_detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF