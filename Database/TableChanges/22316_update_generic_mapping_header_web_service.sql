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
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Handler Class Name'	AND TYPE_ID = 5500
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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Secret Key')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000264', '5500', 'Secret Key', 'Secret Key'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Secret Key'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Authorization')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000265', '5500', 'Authorization', 'Authorization'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Authorization'	AND TYPE_ID = 5500
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Schema')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000268', '5500', 'Schema', 'Schema'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Schema'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Company')
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '-10000269', '5500', 'Company', 'Company'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
	INSERT INTO #insert_output_sdv_external SELECT value_id, [type_id], code FROM static_data_value SDV WHERE code = 'Company'	AND TYPE_ID = 5500
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Param1')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Param1', 'Param1'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Param1'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Param2')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Param2', 'Param2'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Param2'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Param3')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Param3', 'Param3'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Param3'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Param4')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Param4', 'Param4'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Param4'
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

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Secret Key')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Secret Key',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Secret Key'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Secret Key'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Authorization')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Authorization',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Authorization'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Authorization'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Schema')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Schema',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Schema'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Schema'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Company')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Company',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Company'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Company'
END


IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Param1')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Param1',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Param1'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Param1'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Param2')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Param2',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Param2'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Param2'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Param3')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Param3',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Param3'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Param3'
END

IF NOT EXISTS (SELECT 1 FROM   user_defined_fields_template WHERE  Field_label = 'Param4')
BEGIN
    INSERT INTO user_defined_fields_template(field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id )
    SELECT iose.value_id,
           'Param4',
            't',
           'NVARCHAR(1024)',
           'n',
           NULL,
           'h',
           NULL,
           1024,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Param4'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = 1024,
		sql_string = NULL
    WHERE  Field_label = 'Param4'
END


DECLARE @handler_class_name INT
DECLARE @web_service_token_url INT
DECLARE @web_service_url INT
DECLARE @auth_token INT
DECLARE @client_id INT
DECLARE @client_secret INT
DECLARE @grant_type INT
DECLARE @scope INT
DECLARE @secret_key INT
DECLARE @authorization INT
DECLARE @schema INT
DECLARE @company INT
DECLARE @param1 INT
DECLARE @param2 INT
DECLARE @param3 INT
DECLARE @param4 INT


SELECT @handler_class_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Handler Class Name'
SELECT @web_service_token_url = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Web Service Token URL'
SELECT @web_service_url = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Web Service URL'
SELECT @auth_token = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Auth Token'
SELECT @client_id = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Client ID'
SELECT @client_secret = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Client Secret'
SELECT @grant_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Grant Type'
SELECT @scope = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Scope'
SELECT @secret_key = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Secret Key'
SELECT @authorization = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Authorization'
SELECT @schema = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Schema'
SELECT @company = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Company'
SELECT @param1 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Param1'
SELECT @param2 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Param2'
SELECT @param3 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Param3'
SELECT @param4 = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Param4'


/* end of part 2 */
/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Web Service')
BEGIN
	UPDATE gmh
	SET mapping_name = 'Web Service',
		total_columns_used = 12,
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
	16
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
		clm9_label = 'Secret Key',
		clm9_udf_id = @secret_key,
		clm10_label = 'Authorization',
		clm10_udf_id = @authorization,
		clm11_label = 'Schema',
		clm11_udf_id = @schema,
		clm12_label = 'Company',
		clm12_udf_id = @company,
		clm13_label = 'Param1',
		clm13_udf_id = @param1,
		clm14_label = 'Param2',
		clm14_udf_id = @param2,
		clm15_label = 'Param3',
		clm15_udf_id = @param3,
		clm16_label = 'Param4',
		clm16_udf_id = @param4,
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
		clm9_label, clm9_udf_id,
		clm10_label, clm10_udf_id,
		clm11_label, clm11_udf_id,
		clm12_label, clm12_udf_id,
		clm13_label, clm13_udf_id,
		clm14_label, clm14_udf_id,
		clm15_label, clm15_udf_id,
		clm16_label, clm16_udf_id,
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
		'Secret Key', @secret_key,
		'Authorization', @authorization,
		'Schema', @schema,
		'Company', @company,
		'Param1', @param1,
		'Param2', @param2,
		'Param3', @param3,
		'Param4', @param4,
		'1',
		'1'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Web Service'
END

