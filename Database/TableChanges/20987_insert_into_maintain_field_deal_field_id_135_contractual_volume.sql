SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000132)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000132, 5500, 'Contractual volume', 'Contractual volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000132 - Contractual volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000132 - Contractual volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT * FROM maintain_field_deal WHERE farrms_field_id = 'contractual_volume')
BEGIN
	INSERT INTO maintain_field_deal (field_id, farrms_field_id, default_label, field_type, data_type, header_detail, system_required, field_size, is_disable, is_hidden, insert_required, data_flag, update_required)
	VALUES (135, 'contractual_volume', 'Contractual volume', 't', 'number' , 'd', 'n', 230, 'n', 'n', 'n', 'i', 'n')
END
BEGIN
   PRINT 'Contractual volume already exists.' 
END