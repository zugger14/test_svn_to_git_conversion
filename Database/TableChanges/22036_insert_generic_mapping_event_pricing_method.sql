SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5690)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -5690, 'Logical Name', 'Logical Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5690 - Logical Name.'
END
ELSE
BEGIN
    PRINT 'Static data value -5690 - Logical Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Logical Name')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5690, 'Logical Name', 't', 'VARCHAR(100)', 'y', NULL, 'h', 100, -5690
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000230)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000230, 'Holiday', 'Holiday', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000230 - Holiday.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000230 - Holiday already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Holiday')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000230, 'Holiday', 'd', 'VARCHAR(100)', 'n', 'SELECT ''1'' ID, ''Yes'' value UNION SELECT ''0'' ID, ''No'' value', 'h', 100, -10000230
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000231)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000231, 'Include Event', 'Include Event', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000231 - Include Event.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000231 - Include Event already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Include Event')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000231, 'Include Event', 'd', 'VARCHAR(100)', 'n', 'SELECT ''1'' ID, ''Yes'' value UNION SELECT ''2'' ID, ''No'' value order by ID', 'h', 100, -10000231
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000232)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000232, 'Days After', 'Days After', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000232 - Days After.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000232 - Days After already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Days After')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000232, 'Days After', 't', 'VARCHAR(100)', 'n', NULL, 'h', 100, -10000232
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000233)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000233, 'Days Before', 'Days Before', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000233 - Days Before.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000233 - Days Before already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Days Before')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000233, 'Days Before', 't', 'VARCHAR(100)', 'n', NULL, 'h', 100, -10000233
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000235)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000235, 'Pricing Event', 'Pricing Event', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000235 - Pricing Event.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000235 - Pricing Event already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Pricing Event')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000235, 'Pricing Event', 'd', 'VARCHAR(100)', 'n', 'EXEC spa_StaticDataValues ''h'', @type_id = 37800', 'h', 100, -10000235
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000234)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000234, 'Skip Days', 'Skip Days', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000234 - Skip Days.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000234 - Skip Days already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Skip Days')
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000234, 'Skip Days', 't', 'VARCHAR(100)', 'n', NULL, 'h', 100, -10000234
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Event Pricing Method')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Event Pricing Method', 7, 0)
END
ELSE
BEGIN
	UPDATE gmh
	SET mapping_name = 'Event Pricing Method',
		total_columns_used = 7,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Event Pricing Method'
END

DECLARE @BL_LogicalName INT,
		@BL_PricingEvent INT,
		@BL_SkipDays INT,
		@BL_DaysBefore INT,
		@BL_DaysAfter INT,
		@BL_IncludeEvent INT,
		@BL_Holiday INT

SELECT @BL_LogicalName = udf_template_id FROM user_defined_fields_template WHERE Field_id = -5690
SELECT @BL_PricingEvent = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000235
SELECT @BL_SkipDays = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000234
SELECT @BL_DaysBefore = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000233
SELECT @BL_DaysAfter = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000232
SELECT @BL_IncludeEvent = udf_template_id FROM user_defined_fields_template WHERE Field_id = -10000231
SELECT @BL_Holiday = udf_template_id FROM user_defined_fields_template WHERE Field_id = -10000230

DECLARE @mapping_table_id INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Event Pricing Method'

IF NOT EXISTS(SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id=@mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, clm4_label,
		clm4_udf_id, clm5_label, clm5_udf_id, clm6_label, clm6_udf_id, clm7_label, clm7_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'Logical Name', @BL_LogicalName, 'Pricing Event', @BL_PricingEvent, 'Skip Days',
		   @BL_SkipDays, 'Days Before', @BL_DaysBefore, 'Days After', @BL_DaysAfter, 'Include Event', @BL_IncludeEvent,
		   'Holiday',@BL_Holiday, '1'
END
ELSE
BEGIN
	UPDATE gmd
	SET clm1_label = 'Logical Name',
		clm1_udf_id = @BL_LogicalName,
		clm2_label = 'Pricing Event',
		clm2_udf_id = @BL_PricingEvent,
		clm3_label = 'Skip Days',
		clm3_udf_id = @BL_SkipDays,
		clm4_label = 'Days Before',
		clm4_udf_id = @BL_DaysBefore,
		clm5_label = 'Days After',
		clm5_udf_id = @BL_DaysAfter,
		clm6_label = 'Include Event',
		clm6_udf_id = @BL_IncludeEvent,
		clm7_label = 'Holiday',
		clm7_udf_id = @BL_Holiday
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Event Pricing Method'
END

IF NOT EXISTS(SELECT 1 FROM generic_mapping_values WHERE clm1_value = 'B/L 2-1-2')
BEGIN
	INSERT INTO generic_mapping_values(mapping_table_id,clm1_value,clm2_value,clm3_value,clm4_value,clm5_value,clm6_value,clm7_value)
	SELECT @mapping_table_id, 'B/L 2-1-2', '', '0', '2', '2', '1', '1'
END

GO