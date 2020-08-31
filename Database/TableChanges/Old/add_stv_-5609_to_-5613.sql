UPDATE static_data_value
SET    code = code + '_del',
       [description] = [description] + '_del'
WHERE  [type_id] = 5500
       AND value_id > 0
       AND code IN ('Receipt Volume', 'Net Receipt Volume', 'Delivery Volume')

UPDATE user_defined_fields_template
SET    Field_label = Field_label + '_del'
WHERE  Field_label IN ('Receipt Volume', 'Net Receipt Volume', 'Delivery Volume')
       AND field_name > 0

UPDATE user_defined_deal_fields_template
SET    Field_label = Field_label + '_del'
WHERE  Field_label IN ('Receipt Volume', 'Net Receipt Volume', 'Delivery Volume')
       AND field_name > 0

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5609)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5609, 5500, 'Receipt Volume', 'Receipt Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5609 - Receipt Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value -5609 - Receipt Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5610)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5610, 5500, 'Shrinkage', 'Shrinkage', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5610 - Shrinkage.'
END
ELSE
BEGIN
	PRINT 'Static data value -5610 - Shrinkage already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5611)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5611, 5500, 'Net Receipt Volume', 'Net Receipt Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5611 - Net Receipt Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value -5611 - Net Receipt Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5612)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5612, 5500, 'Delivery Volume', 'Delivery Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5612 - Delivery Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value -5612 - Delivery Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5613)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5613, 5500, 'Payback Term', 'Payback Term', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5613 - Payback Term.'
END
ELSE
BEGIN
	PRINT 'Static data value -5613 - Payback Term already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
