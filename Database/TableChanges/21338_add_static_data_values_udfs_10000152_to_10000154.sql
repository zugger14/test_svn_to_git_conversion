SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000152)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000152, 5500, 'Start Time', 'Start Time', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000152 - Start Time.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000152 - Start Time already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000153)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000153, 5500, 'End Time', 'End Time', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000153 - End Time.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000153 - End Time already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000154)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000154, 5500, 'Prorated Volume', 'Prorated Volume', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000154 - Prorated Volume.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000154 - Prorated Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

------------------- Insert UDFs
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000152)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT -10000152, 'Start Time', 'e', 'timestamp', 'n', 'd', 120, -10000152
END 

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000153)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT -10000153, 'End Time', 'e', 'timestamp', 'n', 'd', 120, -10000153
END 

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000154)
BEGIN 
	INSERT INTO user_defined_fields_template(field_name
											, Field_label
											, Field_type
											, data_type
											, is_required
											, udf_type
											, field_size
											, field_id
											)
	SELECT -10000154, 'Prorated Volume', 't', 'numeric(18,0)', 'n', 'd', 120, -10000154
END 