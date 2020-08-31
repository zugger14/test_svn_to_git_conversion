/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
GO
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] NVARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Handler Class Name')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000244', '5500', 'Handler Class Name', 'Handler Class Name'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Web Service Token URL'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Web Service Token URL')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000245', '5500', 'Web Service Token URL', 'Web Service Token URL'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Web Service Token URL'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Web Service URL')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000246', '5500', 'Web Service URL', 'Web Service URL'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Web Service URL'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Auth Token')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000247', '5500', 'Auth Token', 'Auth Token'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Auth Token'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Client ID')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000248', '5500', 'Client ID', 'Client ID'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Client ID'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Client Secret')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000249', '5500', 'Client Secret', 'Client Secret'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Client Secret'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Grant Type')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000250', '5500', 'Grant Type', 'Grant Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Grant Type'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Scope')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000251', '5500', 'Scope', 'Scope'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Scope'	AND TYPE_ID = 5500
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (SELECT * FROM   user_defined_fields_template WHERE  Field_label = 'Handler Class Name')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Handler Class Name',
            't',
           'NVARCHAR(1024)',
           'y',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Handler Class Name'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Handler Class Name'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Web Service Token URL')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Web Service Token URL',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Web Service Token URL'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Web Service Token URL'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Web Service URL')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Web Service URL',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Web Service URL'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Web Service URL'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Auth Token')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Auth Token',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Auth Token'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Auth Token'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Client ID')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Client ID',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Client ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Client ID'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Client Secret')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Client Secret',
           't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Client Secret'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Client Secret'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Grant Type')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Grant Type',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Grant Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Grant Type'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Scope')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Scope',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Scope'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Scope'
END

DECLARE @handler_class_name INT
DECLARE @web_service_token_url INT
DECLARE @web_service_url INT
DECLARE @auth_token INT
DECLARE @client_id INT
DECLARE @client_secret INT
DECLARE @grant_type INT
DECLARE @scope INT

SELECT @handler_class_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Handler Class Name'
SELECT @web_service_token_url = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Web Service Token URL'
SELECT @web_service_url = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Web Service URL'
SELECT @auth_token = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Auth Token'
SELECT @client_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Client ID'
SELECT @client_secret = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Client Secret'
SELECT @grant_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Grant Type'
SELECT @scope = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Scope'

/* end of part 2 */
/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Web Service')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Web Service',
		total_columns_used = 8,
		system_defined = 0
	FROM generic_mapping_header gmh
	WHERE gmh.mapping_name = 'Web Service'		
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Web Service',
	8
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Web Service')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Handler Class Name',
		clm1_udf_id = @handler_class_name,
		clm2_label = 'Web Service Token URL',
		clm2_udf_id = @web_service_token_url,
		clm3_label = 'Web Service URL',
		clm3_udf_id = @web_service_url,
		clm4_label = 'Auth Token',
		clm4_udf_id = @auth_token,
		clm5_label = 'Client ID',
		clm5_udf_id = @client_id,
		clm6_label = 'Client Secret',
		clm6_udf_id = @client_secret,
		clm7_label = 'Grant Type',
		clm7_udf_id = @grant_type,
		clm8_label = 'Scope',
		clm8_udf_id = @scope,
		required_columns_index = '1',
		primary_column_index = '1'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Web Service'
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
		required_columns_index,
		primary_column_index
	)
	SELECT 
		mapping_table_id,
		'Handler Class Name', @handler_class_name,
		'Web Service Token URL', @web_service_token_url,
		'Web Service URL', @web_service_url,
		'Auth Token', @auth_token,
		'Client ID', @client_id,
		'Client Secret', @client_secret,
		'Grant Type', @grant_type,
		'Scope', @scope,
		'1',
		'1'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Web Service'
END

