-- Adding Static Data Value Start
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000271)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000271, 'FTP Username', 'FTP Username', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000271 - FTP Username.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000271 - FTP Username already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000272)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000272, 'FTP Password', 'FTP Password', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000272 - FTP Password.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000272 - FTP Password already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000273)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000273, 'FTP URL', 'FTP URL', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000273 - FTP URL.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000273 - FTP URL already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000274)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000274, 'FTP Path', 'FTP Path', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000274 - FTP Path.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000274 - FTP Path already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

-- Adding Static Data Value End

--Adding UDF Start
IF NOT EXISTS (SELECT * FROM user_defined_fields_template WHERE field_id = -10000271)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000271, 'FTP Username', 't', 'VARCHAR(200)', 'n', '', 'h', NULL, '400', -10000271
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000272)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000272, 'FTP Password', 't', 'VARCHAR(200)', 'n', '', 'h', NULL, '400', -10000272
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000273)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000273, 'FTP URL', 't', 'VARCHAR(200)', 'n', '', 'h', NULL, '400', -10000273
END

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000274)
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000274, 'FTP Path', 't', 'VARCHAR(200)', 'n', '', 'h', NULL, '400', -10000274
END

--Adding UDF End


--Insert Generic mapping header start
IF EXISTS (SELECT * FROM generic_mapping_header WHERE mapping_name = 'Gasum SFTP Folder Configuration')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Gasum SFTP Folder Configuration',
		total_columns_used = 4
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Gasum SFTP Folder Configuration'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used)
	VALUES ('Gasum SFTP Folder Configuration', 4)
END
--Insert Generic mapping header end

--Insert Generic mapping definition start
DECLARE @Username INT, @Password INT, @URL INT, @Path INT

SELECT @Username = udf_template_id FROM user_defined_fields_template WHERE field_label = 'FTP Username'
SELECT @Password = udf_template_id FROM user_defined_fields_template WHERE field_label = 'FTP Password' 
SELECT @URL = udf_template_id FROM user_defined_fields_template WHERE field_label = 'FTP URL'
SELECT @Path = udf_template_id FROM user_defined_fields_template WHERE field_label = 'FTP Path'
	
IF EXISTS (
	SELECT 1 
	FROM generic_mapping_definition gmd 
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
	WHERE gmh.mapping_name = 'Gasum SFTP Folder Configuration'
)
BEGIN
	UPDATE gmd
	SET clm1_label = 'Username',
		clm1_udf_id = @Username,
		clm2_label = 'Password',
		clm2_udf_id = @Password,
		clm3_label = 'URL',
		clm3_udf_id = @URL,
		clm4_label = 'Path',
		clm4_udf_id = @Path
	FROM generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id		
	WHERE gmh.mapping_name = 'Gasum SFTP Folder Configuration'
END
ELSE
BEGIN
	INSERT INTO generic_mapping_definition (
		mapping_table_id,
		clm1_label, clm1_udf_id,
		clm2_label, clm2_udf_id,
		clm3_label, clm3_udf_id,
		clm4_label, clm4_udf_id
	)
	SELECT 
		mapping_table_id,
		'Username', @Username,
		'Password', @Password,
		'URL', @URL,
		'Path', @Path
	FROM generic_mapping_header 
	WHERE mapping_name = 'Gasum SFTP Folder Configuration'
END
--Insert Generic mapping definition end
