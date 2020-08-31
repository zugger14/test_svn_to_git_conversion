SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4072)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4072, 4011, 'source_deal_detail_rwe_de', 'source_deal_detail_rwe_de', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4072 - source_deal_detail_rwe_de.'
END
ELSE
BEGIN
	PRINT 'Static data value 4072 - source_deal_detail_rwe_de already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF