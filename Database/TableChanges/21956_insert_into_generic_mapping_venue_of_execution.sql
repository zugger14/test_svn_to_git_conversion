--Insert Static Data Start
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000213)
BEGIN
	DELETE FROM static_data_value WHERE code = 'MIC Country' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000213, 'MIC Country', 'MIC Country', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000213 - MIC Country.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000213 - MIC Country already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000214)
BEGIN
	DELETE FROM static_data_value WHERE code = 'MIC Country Code' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000214, 'MIC Country Code', 'MIC Country Code', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000214 - MIC Country Code.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000214 - MIC Country Code already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000215)
BEGIN
	DELETE FROM static_data_value WHERE code = 'MIC' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000215, 'MIC', 'MIC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000215 - MIC.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000215 - MIC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000216)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Operating MIC' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000216, 'Operating MIC', 'Operating MIC', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000216 - Operating MIC.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000216 - Operating MIC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000217)
BEGIN
	DELETE FROM static_data_value WHERE code = 'O/S' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000217, 'O/S', 'Operating System', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000217 - O/S.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000217 - O/S already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000218)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Name-Institution Desc' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000218, 'Name-Institution Desc', 'Name-Institution Desc', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000218 - Name-Institution Desc.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000218 - Name-Institution Desc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000219)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Acronym' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000219, 'Acronym', 'Acronym', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000219 - Acronym.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000219 - Acronym already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000220)
BEGIN
	DELETE FROM static_data_value WHERE code = 'City' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000220, 'City', 'City', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000220 - City.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000220 - City already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000221)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Website' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000221, 'Website', 'Website', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000221 - Website.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000221 - Website already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5688)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Status' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -5688, 'Status', 'Status', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -5688 - Status.'
END
ELSE
BEGIN
    PRINT 'Static data value -5688 - Status already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000222)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Status Date' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000222, 'Status Date', 'Status Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000222 - Status Date.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000222 - Status Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000223)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Creation Date' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000223, 'Creation Date', 'Creation Date', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000223 - Creation Date.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000223 - Creation Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000224)
BEGIN
	DELETE FROM static_data_value WHERE code = 'Comments' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000224, 'Comments', 'Comments', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000224 - Comments.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000224 - Comments already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000020)
BEGIN
	DELETE FROM static_data_value WHERE code = 'EEA' AND type_id = 5500
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000020, 'EEA', 'EEA', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000020 - EEA.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000020 - EEA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       
--Insert Static Data END
	
--Insert UDF Start
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000020)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000020, 'EEA', 'd', 'VARCHAR(150)', 'n', 'SELECT ''y'' id, ''Yes'' code UNION ALL SELECT ''n'', ''No''', 'h', NULL, '400', -10000020
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -5688)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -5688, 'Status', 't', 'varchar(500)', 'n', NULL, 'h', NULL, '120', -5688
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000213)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000213, 'MIC Country', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000213
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000214)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000214, 'MIC Country Code', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000214
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000215)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000215, 'MIC', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000215
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000216)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000216, 'Operating MIC', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000216
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000217)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000217, 'O/S', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000217
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000218)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000218, 'Name-Institution Desc', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000218
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000219)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000219, 'Acronym', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000219
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000220)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000220, 'City', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000220
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000221)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000221, 'Website', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000221
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000222)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000222, 'Status Date', 'a', 'DATETIME', 'n', '', 'h', NULL, '400', -10000222
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000223)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000223, 'Creation Date', 'a', 'DATETIME', 'n', '', 'h', NULL, '400', -10000223
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000224)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000224, 'Comments', 't', 'VARCHAR(150)', 'n', '', 'h', NULL, '400', -10000224
END
--Insert UDF Start

--Insert Generic mapping header start
IF EXISTS (SELECT * FROM generic_mapping_header WHERE mapping_name = 'Venue of Execution')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Venue of Execution',
		total_columns_used = 14
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Venue of Execution'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used)
	VALUES ('Venue of Execution', 14)
END
--Insert Generic mapping header end

--Insert Generic mapping definition start
DECLARE @eea INT, @status INT, @mic_country INT, @mic_country_code INT, @mic INT, @operating_mic INT, @os INT,
		@name_institution_desc INT, @acronym INT, @city INT, @website INT, @status_date INT, @creation_date INT,
		@comments INT

SELECT @eea = udf_template_id FROM user_defined_fields_template WHERE field_label = 'EEA'
SELECT @status = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Status'
SELECT @mic_country = udf_template_id FROM user_defined_fields_template WHERE field_label = 'MIC Country'
SELECT @mic_country_code = udf_template_id FROM user_defined_fields_template WHERE field_label = 'MIC Country Code'
SELECT @mic = udf_template_id FROM user_defined_fields_template WHERE field_label = 'MIC'
SELECT @operating_mic = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Operating MIC'
SELECT @os = udf_template_id FROM user_defined_fields_template WHERE field_label = 'O/S'
SELECT @name_institution_desc = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Name-Institution Desc'
SELECT @acronym = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Acronym'
SELECT @city = udf_template_id FROM user_defined_fields_template WHERE field_label = 'City'
SELECT @website = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Website'
SELECT @status_date = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Status Date'
SELECT @creation_date = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Creation Date'
SELECT @comments = udf_template_id FROM user_defined_fields_template WHERE field_label = 'Comments'
	
IF EXISTS (
	SELECT 1 
	FROM generic_mapping_definition gmd 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Venue of Execution'
)
BEGIN
	UPDATE gmd
	SET clm1_label = 'MIC Country',
		clm1_udf_id = @mic_country,
		clm2_label = 'MIC Country Code',
		clm2_udf_id = @mic_country_code,
		clm3_label = 'MIC',
		clm3_udf_id = @mic,
		clm4_label = 'Operating MIC',
		clm4_udf_id = @operating_mic,
		clm5_label = 'O/S',
		clm5_udf_id = @os,
		clm6_label = 'Name-Institution Desc',
		clm6_udf_id = @name_institution_desc,
		clm7_label = 'Acronym',
		clm7_udf_id = @acronym,
		clm8_label = 'City',
		clm8_udf_id = @city,
		clm9_label = 'Website',
		clm9_udf_id = @website,
		clm10_label = 'Status Date',
		clm10_udf_id = @status_date,
		clm11_label = 'Status',
		clm11_udf_id = @status,
		clm12_label = 'Creation Date',
		clm12_udf_id = @creation_date,
		clm13_label = 'Comments',
		clm13_udf_id = @comments,
		clm14_label = 'EEA',
		clm14_udf_id = @eea			
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id		
	WHERE gmh.mapping_name = 'Venue of Execution'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id,
		clm5_label, clm5_udf_id,
		clm6_label, clm6_udf_id,
		clm7_label, clm7_udf_id,
		clm8_label, clm8_udf_id,
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id,
		clm11_label, clm11_udf_id,
		clm12_label, clm12_udf_id,
		clm13_label, clm13_udf_id,
		clm14_label, clm14_udf_id
	)
	SELECT 
		mapping_table_id,
		'MIC Country', @mic_country,
		'MIC Country Code', @mic_country_code,
		'MIC', @mic,
		'Operating MIC', @operating_mic,
		'O/S', @os,
		'Name-Institution Desc', @name_institution_desc,
		'Acronym', @acronym,
		'City', @city,
		'Website', @website,
		'Status Date', @status_date,
		'Status', @status,
		'Creation Date', @creation_date,
		'Comments', @comments,
		'EEA', @eea		
	FROM generic_mapping_header 
	WHERE mapping_name = 'Venue of Execution'
END
--Insert Generic mapping definition end
