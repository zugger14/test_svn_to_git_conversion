/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500), [description] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -5698)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5698, 5500, 'Effective Date', 'Effective Date'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Effective Date'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000309)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000309, 5500, 'Counterparty Type', 'Counterparty Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Counterparty Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -5500)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5500, 5500, 'Commodity', 'Commodity'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000316)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000316, 5500, 'Reseller Certificate', 'Reseller Certificate'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Reseller Certificate'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000317)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000317, 5500, 'Energy Tax Exemption', 'Energy Tax Exemption'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Energy Tax Exemption'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000318)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000318, 5500, 'Document Type', 'Document Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Document Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000319)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000319, 5500, 'Price', 'Price'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Price'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -5723)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -5723, 5500, 'Charge Type', 'Charge Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Charge Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000308)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000308, 5500, 'Tax Type', 'Tax Type'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tax Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000320)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000320, 5500, 'Tax Unit', 'Tax Unit'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tax Unit'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000321)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000321, 5500, 'Tax %', 'Tax %'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tax %'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000322)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000322, 5500, 'Tax Remarks', 'Tax Remarks'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Tax Remarks'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND value_id = -10000323)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code, INSERTED.[description]
		INTO #insert_output_sdv_external
	SELECT -10000323, 5500, 'Region Id', 'Region Id'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code, [description]
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Region Id'
END


/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Effective Date'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Effective Date',
           'a',
           'DATETIME',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Effective Date'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
	Field_type ='a',
	data_type = 'DATETIME',
		sql_string = NULL
    WHERE  Field_label = 'Effective Date'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Region Id'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Region Id',
           'd',
           'NVARCHAR(150)',
           'y',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Region Id'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 11150'
    WHERE  Field_label = 'Region Id'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Counterparty Type',
           'd',
           'VARCHAR(10)',
           'n',
           'SELECT ''i'' [id], ''Internal'' [value] UNION SELECT ''e'' [id], ''External'' [value] UNION SELECT ''b'' [id], ''Broker'' [value] UNION SELECT ''c'' [id], ''Clearing'' [value]',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT ''i'' [id], ''Internal'' [value] UNION SELECT ''e'' [id], ''External'' [value] UNION SELECT ''b'' [id], ''Broker'' [value] UNION SELECT ''c'' [id], ''Clearing'' [value]' 
    WHERE  Field_label = 'Counterparty Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Commodity'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Commodity',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT source_commodity_id [id], commodity_name [value] FROM source_commodity',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT source_commodity_id [id], commodity_name [value] FROM source_commodity'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Reseller Certificate'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Reseller Certificate',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT  ''y'' [id], ''Yes'' [value] UNION ALL SELECT  ''n'' [id], ''No'' [value]',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Reseller Certificate'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT  ''y'' [id], ''Yes'' [value] UNION ALL SELECT  ''n'' [id], ''No'' [value]'
    WHERE  Field_label = 'Reseller Certificate'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Energy Tax Exemption'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Energy Tax Exemption',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT  ''y'' [id], ''Yes'' [value] UNION ALL SELECT  ''n'' [id], ''No'' [value]',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Energy Tax Exemption'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT  ''y'' [id], ''Yes'' [value] UNION ALL SELECT  ''n'' [id], ''No'' [value]'
    WHERE  Field_label = 'Energy Tax Exemption'
END
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Document Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Document Type',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT ''i'',''Invoice'' UNION SELECT ''r'',''Remittance'' UNION SELECT ''b'',''Both''',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Document Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT ''i'',''Invoice'' UNION SELECT ''r'',''Remittance'' UNION SELECT ''b'',''Both'''
    WHERE  Field_label = 'Document Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Price'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Price',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT ''p'' [id],''Positive'' [value] UNION SELECT ''n'' [id],''Negative'' [value] UNION SELECT ''b'' [id],''Both'' [value]',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Price'
END
ELSE	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT ''p'' [id],''Positive'' [value] UNION SELECT ''n'' [id],''Negative'' [value] UNION SELECT ''b'' [id],''Both'' [value]'
    WHERE  Field_label = 'Price'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Charge Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Charge Type',
           'd',
           'NVARCHAR(250)',
           'n',
           'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Charge Type'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT value_id id, code value FROM static_data_value sdv WHERE sdv.[type_id] = 10019 ORDER BY 2'
    WHERE  Field_label = 'Charge Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Tax Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Tax Type',
           'd',
           'NVARCHAR(150)',
           'n',
           'SELECT  ''e'' [id], ''Energy Tax'' [value] UNION ALL SELECT  ''v'' [id], ''VAT'' [value]',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Tax Type'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = 'SELECT  ''e'' [id], ''Energy Tax'' [value] UNION ALL SELECT  ''v'' [id], ''VAT'' [value]'
    WHERE  Field_label = 'Tax Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Tax Unit'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Tax Unit',
           't',
           'NVARCHAR(150)',
           'n',
           NULL,
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Tax Unit'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = NULL
    WHERE  Field_label = 'Tax Unit'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Tax %'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Tax %',
           't',
           'NUMERIC(38,20)',
           'n',
           '',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Tax %'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = ''
    WHERE  Field_label = 'Tax %'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Tax Remarks'
   )
BEGIN
    INSERT INTO user_defined_fields_template
      (
        field_name,
        Field_label,
        Field_type,
        data_type,
        is_required,
        sql_string,
        udf_type,
        sequence,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Tax Remarks',
           't',
           'NVARCHAR(4000)',
           'n',
           '',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Tax Remarks'
END
ELSE
	
BEGIN
    UPDATE user_defined_fields_template
	SET field_size = NULL,
		sql_string = ''
    WHERE  Field_label = 'Tax Remarks'
END


/*****************************************
Step 3: Insert into generic_mapping_header
******************************************/
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Tax Rules')
BEGIN
	UPDATE generic_mapping_header
	SET total_columns_used = 13
	WHERE mapping_name = 'Tax Rules'
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Tax Rules',
	13
	)
END

/*********************************************
Step 4: Insert into generic_mapping_definition
**********************************************/
DECLARE @effective_date_id INT
DECLARE @region_id INT
DECLARE @counterparty_type_id INT
DECLARE @commodity INT
DECLARE @reseller_certificate INT
DECLARE @energy_tax_exemption INT
DECLARE @document_type INT
DECLARE @price INT
DECLARE @charge_type INT
DECLARE @tax_type INT
DECLARE @tax_unit INT
DECLARE @tax_per INT
DECLARE @tax_remarks INT

SELECT @effective_date_id = udf_template_id FROM user_defined_fields_template WHERE field_id = -5698
SELECT @region_id = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000323
SELECT @counterparty_type_id = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000309
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE field_id = -5500
SELECT @reseller_certificate = udf_template_id FROM user_defined_fields_template WHERE field_id =  -10000316
SELECT @energy_tax_exemption = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000317
SELECT @document_type = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000318
SELECT @price = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000319
SELECT @charge_type = udf_template_id FROM user_defined_fields_template WHERE field_id = -5723
SELECT @tax_type = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000308
SELECT @tax_unit = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000320
SELECT @tax_per = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000321
SELECT @tax_remarks = udf_template_id FROM user_defined_fields_template WHERE field_id = -10000322

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Tax Rules')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Effective Date',
		clm1_udf_id = @effective_date_id,
		clm2_label = 'Region Id',
		clm2_udf_id = @region_id,
		clm3_label = 'Counterparty Type',
		clm3_udf_id = @counterparty_type_id,
		clm4_label = 'Commodity',
		clm4_udf_id = @commodity,
		clm5_label = 'Reseller Certificate',
		clm5_udf_id = @reseller_certificate,
		clm6_label = 'Energy Tax Exemption',
		clm6_udf_id = @energy_tax_exemption,
		clm7_label = 'Document Type',
		clm7_udf_id = @document_type,
		clm8_label = 'Price',
		clm8_udf_id = @price,
		clm9_label = 'Charge Type',
		clm9_udf_id = @charge_type,
		clm10_label = 'Tax Type',
		clm10_udf_id = @tax_type,
		clm11_label = 'Tax Unit',
		clm11_udf_id = @tax_unit,
		clm12_label = 'Tax %',
		clm12_udf_id = @tax_per,
		clm13_label = 'Tax Remarks',
		clm13_udf_id = @tax_remarks
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Tax Rules'
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
		unique_columns_index,
		required_columns_index				
	)
	SELECT 
		mapping_table_id,
		'Effective Date', @effective_date_id,
		'Region Id', @region_id,
		'Counterparty Type',@counterparty_type_id,
		'Commodity',@commodity,
		'Reseller Certificate',@reseller_certificate,
		'Energy Tax Exemption',@energy_tax_exemption,
		'Document Type',@document_type,
		'Price',@price,
		'Charge Type',@charge_type,
		'Tax Type',@tax_type,
		'Tax Unit',@tax_unit,
		'Tax %',@tax_per,
		'Tax Remarks',@tax_remarks,
		NULL,
		'2'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Tax Rules'
END

