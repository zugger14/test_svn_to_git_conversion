-- Static Data
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500)) 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000325)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000325, 'Process Type', 'Process Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000325 - Process.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000325 - Process already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5674)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -5674, 'Sub Book', 'Sub Book', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5674 - Sub Book.'
END
ELSE
BEGIN
    PRINT 'Static data value -5674 - Sub Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000337)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000337, 'Source Profile 1', 'Source Profile 1', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000337 - Source Profile 1.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000337 - Source Profile 1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT * FROM static_data_value WHERE value_id = -10000338)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000338, 'Source Profile 2', 'Source Profile 2', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000338 - Source Profile 2.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000338 - Source Profile 2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000339)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000339, 'Destination Buy Profile', 'Destination Buy Profile', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000339 - Destination Buy Profile.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000339 - Destination Buy Profile already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000340)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000340, 'Destination Sell Profile', 'Destination Sell Profile', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000340 - Destination Sell Profile.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000340 - Destination Sell Profile already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
-- positive UDF
IF NOT EXISTS (SELECT * FROM static_data_value WHERE [type_id] = 5500 AND code = 'Location')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Location', 'Location'
END
ELSE 
BEGIN
	INSERT INTO #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Location'
END

---- UDF Template
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000325)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000325, 'Process Type', 'd', 'NVARCHAR(250)', 'n', 'EXEC spa_staticdatavalues @flag = ''h'', @type_id = 112700', 'h', 100, -10000325
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -5674)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -5674, 'Sub Book', 'd', 'NVARCHAR(250)', 'y', 'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2', 'h', 150, -5674
END
ELSE
BEGIN
	UPDATE user_defined_fields_template
	SET sql_string = 'SELECT ssbm.book_deal_type_map_id id, ssbm.logical_name VALUE FROM source_system_book_map ssbm ORDER BY 2'
	WHERE field_id = -5674
END


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000337)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000337, 'Source Profile 1', 'd', 'NVARCHAR(100)', 'y', 'spa_forecast_profile @flag = ''x'', @profile_type_id = 17500', 'h', 100, -10000337
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000338)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000338, 'Source Profile 2', 'd', 'NVARCHAR(100)', 'y', 'spa_forecast_profile @flag = ''x'', @profile_type_id = 17500', 'h', 100, -10000338
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000339)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000339, 'Destination Buy Profile', 'd', 'NVARCHAR(100)', 'y', 'spa_forecast_profile @flag = ''x'', @profile_type_id = 17500', 'h', 100, -10000339
END

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000340)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000340, 'Destination Sell Profile', 'd', 'NVARCHAR(100)', 'y', 'spa_forecast_profile @flag = ''x'', @profile_type_id = 17500', 'h', 100, -10000340
END

IF NOT EXISTS (
		SELECT *
		FROM user_defined_fields_template
		WHERE Field_label = 'Location'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Location',
           'd',
           'NVARCHAR(250)',
           'n',
           'EXEC spa_source_minor_location ''o''',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Location'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd'
    WHERE  Field_label = 'Location'
END

-- Generic Mapping Table 
IF NOT EXISTS( SELECT * FROM generic_mapping_header WHERE mapping_name = 'Retail Gas Delta Volume')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used, system_defined)
	VALUES('Retail Gas Delta Volume', 7, 0)
END

-- Mapping Definition
DECLARE @mapping_table_id INT
	  , @process INT
	  , @sub_book INT
	  , @location INT
	  , @profile1 INT
	  , @profile2 INT
	  , @dest_buy_profile INT
	  , @dest_sell_profile INT

SELECT @mapping_table_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Retail Gas Delta Volume'

SELECT @process = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000325

SELECT @sub_book = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -5674

SELECT @location = udf_template_id
FROM user_defined_fields_template 
WHERE Field_id = (SELECT field_id FROM user_defined_fields_template WHERE Field_label = 'Location')

SELECT @profile1 = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000337

SELECT @profile2 = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000338

SELECT @dest_buy_profile = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000339

SELECT @dest_sell_profile = udf_template_id 
FROM user_defined_fields_template 
WHERE Field_id = -10000340

IF NOT EXISTS (SELECT 1 FROM generic_mapping_definition WHERE mapping_table_id = @mapping_table_id)
BEGIN
	INSERT INTO generic_mapping_definition(
		mapping_table_id, clm1_label, clm1_udf_id,clm2_label, clm2_udf_id,clm3_label, clm3_udf_id,clm4_label
		, clm4_udf_id,clm5_label, clm5_udf_id,clm6_label, clm6_udf_id,clm7_label, clm7_udf_id, unique_columns_index
	)
	SELECT @mapping_table_id, 'ST Process', @process, 'Sub Book', @sub_book, 'Location', @location
		, 'Source Profile 1', @profile1, 'Source Profile 2', @profile2, 'Destination Buy Profile', @dest_buy_profile
		, 'Destination Sell Profile', @dest_sell_profile, '1,2,3,4,5'
END
ELSE
BEGIN
	UPDATE gmd
	SET	clm1_label	= 'Process Type'
		, clm1_udf_id = @process
		, clm2_label = 'Sub Book'
		, clm2_udf_id = @sub_book
		, clm3_label = 'Location'
		, clm3_udf_id = @location
		, clm4_label = 'Source Profile 1'
		, clm4_udf_id = @profile1
		, clm5_label = 'Source Profile 2'
		, clm5_udf_id = @profile2
		, clm6_label = 'Destination Buy Profile'
		, clm6_udf_id = @dest_buy_profile
		, clm7_label = 'Destination Sell Profile'
		, clm7_udf_id = @dest_sell_profile
		, unique_columns_index = '1,2,3,4,5'
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh 
		ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Retail Gas Delta Volume'
END

