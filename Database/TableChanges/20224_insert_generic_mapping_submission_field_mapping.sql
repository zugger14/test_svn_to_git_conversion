/*Step 1:Create a UDF */

IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
 
CREATE TABLE #insert_output_sdv_external
 
(
      value_id     INT,
      [type_id]    INT,
      [type_name]  VARCHAR(500)
)
 
-- First UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Counterparty')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Counterparty',
           'Counterparty'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500
           AND [code] = 'Counterparty'
END
 
--Second UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Contract')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Contract',
           'Contract'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Contract'
END

--Third UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Book')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Book',
           'Book'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Book'
END

--Forth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Type')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Deal Type',
           'Deal Type'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END

--Fifth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Sub Type')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Deal Sub Type',
           'Deal Sub Type'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Deal Sub Type'
END

--Sixth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Commodity',
           'Commodity'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

--Seventh UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Template')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Template',
           'Template'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Template'
END

--Eighth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Confirmation Status')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Confirmation Status',
           'Confirmation Status'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Confirmation Status'
END

--Ninth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Status')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Deal Status',
           'Deal Status'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Deal Status'
END

--Tenth UDF
 
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Submission Type')
 
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      ) OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
    SELECT '5500',
           'Submission Type',
           'Submission Type'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500 AND [code] = 'Submission Type'
END


/*Step 2: Defining UDF */
 --First UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Counterparty'
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
           'Counterparty',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_counterparty_id, counterparty_name FROM source_counterparty WHERE is_active = ''y'' ORDER BY counterparty_name',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Counterparty'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT source_counterparty_id , counterparty_name FROM source_counterparty WHERE is_active = ''y'' ORDER BY counterparty_name'
    WHERE  Field_label = 'Counterparty'
END


--Second UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Contract'
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
           'Contract',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT contract_id, contract_name FROM contract_group value ORDER BY contract_name',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Contract'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT contract_id , contract_name FROM contract_group value ORDER BY contract_name'
    WHERE  Field_label = 'Contract'
END

--Third UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Book'
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
           'Book',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT entity_id, entity_name FROM portfolio_hierarchy WHERE hierarchy_level = 0 ORDER BY entity_name',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Book'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT entity_id, entity_name FROM portfolio_hierarchy WHERE hierarchy_level = 0 ORDER BY entity_name'
    WHERE  Field_label = 'Book'
END

--Forth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Type'
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
           'Deal Type',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_deal_type_id, source_deal_type_name FROM source_deal_type ORDER BY source_deal_type_name',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT source_deal_type_id,source_deal_type_name FROM source_deal_type  WHERE 1 = 1  AND ISNULL(sub_type, ''n'') = ''n'' ORDER BY source_deal_type_name'
    WHERE  Field_label = 'Deal Type'
END

--Fifth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Sub Type'
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
           'Deal Sub Type',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT source_deal_type_id, source_deal_type_name FROM  source_deal_type WHERE 1 = 1  AND ISNULL(sub_type, ''n'') = ''y'' ORDER BY source_deal_type_name 
	                   ',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Sub Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT source_deal_type_id, source_deal_type_name FROM  source_deal_type WHERE 1 = 1  AND ISNULL(sub_type, ''n'') = ''y'' ORDER BY source_deal_type_name'
    WHERE  Field_label = 'Deal Sub Type'
END

--Sixth UDF
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
           'VARCHAR(150)',
           'y',
           'SELECT source_commodity_id, commodity_id FROM source_commodity sc ORDER BY commodity_id',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT source_commodity_id, commodity_id FROM source_commodity sc ORDER BY commodity_id'
    WHERE  Field_label = 'Commodity'
END

--Seventh UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Template'
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
           'Template',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT DISTINCT template_id, template_name FROM source_deal_header_template sdht LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id WHERE sdht.is_active = ''y'' ORDER BY template_name',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT DISTINCT template_id, template_name FROM source_deal_header_template sdht LEFT OUTER JOIN source_deal_type sdt ON  sdht.source_deal_type_id = sdt.source_deal_type_id  LEFT JOIN deal_template_privilages sdp ON sdp.deal_template_id = sdht.template_id WHERE sdht.is_active = ''y'' ORDER BY template_name'
    WHERE  Field_label = 'Template'
END

--Eight UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Confirmation Status'
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
           'Confirmation Status',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=17200 ORDER BY code',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Confirmation Status'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=17200 ORDER BY code'
    WHERE  Field_label = 'Confirmation Status'
END

--Ninth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Status'
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
           'Deal Status',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=5600 ORDER BY code',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Status'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=5600 ORDER BY code'
    WHERE  Field_label = 'Deal Status'
END

--Tenth UDF
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Submission Type'
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
           'Submission Type',
           'd',
           'VARCHAR(150)',
           'y',
           'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=44700 ORDER BY code',
           'h',
           NULL,
           180,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Submission Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string =  'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=44700 ORDER BY code'
    WHERE  Field_label = 'Submission Type'
END

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Submission Field Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Submission Field Mapping',
	10
	)
END

/* step 4: Insert into Generic Mapping Defination*/

DECLARE @counterparty INT
DECLARE @contract INT
DECLARE @book INT 
DECLARE @deal_type INT 
DECLARE @deal_sub_type INT 
DECLARE @commodity INT 
DECLARE @template INT 
DECLARE @confimation_status INT 
DECLARE @deal_status INT 
DECLARE @submission_type INT 

SELECT @counterparty= udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Counterparty'
SELECT @contract = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Contract'
SELECT @book = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Book'
SELECT @deal_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @deal_sub_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Sub Type'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Template'
SELECT @confimation_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Confirmation Status'
SELECT @deal_status = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Status'
SELECT @submission_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Submission Type'


IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Submission Field Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Counterparty',
		clm1_udf_id = @counterparty,
		clm2_label = 'Contract',
		clm2_udf_id = @contract,
		clm3_label = 'Book',
		clm3_udf_id = @book,
		clm4_label = 'Deal Type',
		clm4_udf_id = @deal_type,
		clm5_label = 'Deal Sub Type',
		clm5_udf_id = @deal_sub_type,
		clm6_label = 'Commodity',
		clm6_udf_id = @commodity,
		clm7_label = 'Template',
		clm7_udf_id = @template,
		clm8_label = 'Confirmation Status',
		clm8_udf_id = @confimation_status,
		clm9_label = 'Deal Status',
		clm9_udf_id = @deal_status,
		clm10_label = 'Submission Type',
		clm10_udf_id = @submission_type
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Submission Field Mapping'
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
		clm10_label, clm10_udf_id
	)
	SELECT 
		mapping_table_id,
		'Counterparty', @counterparty,
		'Contract', @contract,
		'Book', @book,
		'Deal Type', @deal_type,
		'Deal Sub Type', @deal_sub_type,
		'Commodity', @commodity,
		'Template', @template,
		'Confirmation Status', @confimation_status,
		'Deal Status', @deal_status,
		'Submission Type', @submission_type
	FROM generic_mapping_header 
	WHERE mapping_name = 'Submission Field Mapping'
END
