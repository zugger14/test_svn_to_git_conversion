SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4055)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4055, 4011, 'source_deal_detail_trm_essent_excel', 'Table to import the excel deal import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4055 - source_deal_detail_trm_essent_excel.'
END
ELSE
BEGIN
	PRINT 'Static data value 4055 - source_deal_detail_trm_essent_excel already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
