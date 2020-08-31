SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2178)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2178, 2175, 'source_deal_detail_audit', 'Transaction Audit Log', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2178 - source_deal_detail_audit.'
END
ELSE
BEGIN
	PRINT 'Static data value 2178 - source_deal_detail_audit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF