SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -909)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-909, 800, 'PriorInvoiceAdjustment', 'Return the adjustment(difference of values for a production month run between two dates)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -909 - PriorInvoiceAdjustment.'
END
ELSE
BEGIN
	PRINT 'Static data value -909 - PriorInvoiceAdjustment already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF