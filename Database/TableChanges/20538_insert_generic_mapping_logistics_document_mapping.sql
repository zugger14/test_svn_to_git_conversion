/* step 1 start*/
IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Template', 'Deal Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Template'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Commodity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Commodity', 'Commodity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Origin')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Origin', 'Origin'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Origin'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Type', 'Deal Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Deal Sub-Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Deal Sub-Type', 'Deal Sub-Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Sub-Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Buy Inco Terms')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Buy Inco Terms', 'Buy Inco Terms'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Buy Inco Terms'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sell Inco Terms')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Sell Inco Terms', 'Sell Inco Terms'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sell Inco Terms'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Buy Payments Terms')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Buy Payments Terms', 'Buy Payments Terms'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Buy Payments Terms'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sell Payments Terms')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Sell Payments Terms', 'Sell Payments Terms'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sell Payments Terms'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Scheduling/Ticket')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Scheduling/Ticket', 'Scheduling/Ticket'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Scheduling/Ticket'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Document Category')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Document Category', 'Document Category'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Document Category'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Document Template')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Document Template', 'Document Template'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Document Template'
END

/* step 1 end */

/* step 2 start*/
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Template'
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
           'Deal Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM source_deal_header_template',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT template_id, template_name FROM source_deal_header_template'
    WHERE  Field_label = 'Deal Template'
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
           'VARCHAR(150)',
           'n',
           'SELECT source_commodity_id, commodity_name FROM source_commodity',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Commodity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_commodity_id, commodity_name FROM source_commodity'
    WHERE  Field_label = 'Commodity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Origin'
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
           'Origin',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 14000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Origin'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 14000'
    WHERE  Field_label = 'Origin'
END

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
           'n',
           'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n'''
    WHERE  Field_label = 'Deal Type'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Sub-Type'
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
           'Deal Sub-Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''y''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Deal Sub-Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''y'''
    WHERE  Field_label = 'Deal Sub-Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Buy Inco Terms'
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
           'Buy Inco Terms',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 40200',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Buy Inco Terms'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 40200'
    WHERE  Field_label = 'Buy Inco Terms'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sell Inco Terms'
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
           'Sell Inco Terms',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 40200',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sell Inco Terms'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 40200'
    WHERE  Field_label = 'Sell Inco Terms'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Buy Payments Terms'
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
           'Buy Payments Terms',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 20000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Buy Payments Terms'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 20000'
    WHERE  Field_label = 'Buy Payments Terms'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sell Payments Terms'
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
           'Sell Payments Terms',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id, code FROM static_data_value where type_id = 20000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sell Payments Terms'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id, code FROM static_data_value where type_id = 20000'
    WHERE  Field_label = 'Sell Payments Terms'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Scheduling/Ticket'
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
           'Scheduling/Ticket',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''s'' [id], ''Scheduling'' [value] UNION ALL SELECT ''t'' [id], ''Ticket'' [value] UNION ALL SELECT ''b'', ''Scheduling & Ticket''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Scheduling/Ticket'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT ''s'' [id], ''Scheduling'' [value] UNION ALL SELECT ''t'' [id], ''Ticket'' [value] UNION ALL SELECT ''b'', ''Scheduling & Ticket'''
    WHERE  Field_label = 'Scheduling/Ticket'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Document Category'
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
           'Document Category',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT value_id,code FROM static_data_value WHERE type_id = 42000 AND category_id = 45',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Document Category'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT value_id,code FROM static_data_value WHERE type_id = 42000 AND category_id = 45'
    WHERE  Field_label = 'Document Category'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Document Template'
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
           'Document Template',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT template_id, template_name FROM Contract_report_template where template_type IN (45,43)',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Document Template'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT template_id, template_name FROM Contract_report_template where template_type IN (45,43)'
    WHERE  Field_label = 'Document Template'
END

/* end of part 2 */

/* Step3: Insert Generic Mapping Header */

IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Logistics Document Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Logistics Document Mapping',
	12
	)
END

 /* step 4: Insert into Generic Mapping Defination*/
DECLARE @deal_template INT
DECLARE @commodity INT
DECLARE @origin INT
DECLARE @deal_type INT
DECLARE @deal_sub_type INT
DECLARE @buy_inco_term INT
DECLARE @sell_inco_term INT
DECLARE @buy_payments_term INT
DECLARE @sell_payments_term INT
DECLARE @scheduling_ticket INT
DECLARE @document_category INT
DECLARE @document_template INT

SELECT @deal_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Template'
SELECT @commodity = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Commodity'
SELECT @origin = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Origin'  
SELECT @deal_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Type'
SELECT @deal_sub_type = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Deal Sub-Type'  
SELECT @buy_inco_term = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy Inco Terms'
SELECT @sell_inco_term = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sell Inco Terms'
SELECT @buy_payments_term = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Buy Payments Terms'
SELECT @sell_payments_term = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sell Payments Terms'
SELECT @scheduling_ticket = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Scheduling/Ticket'
SELECT @document_category = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Document Category'
SELECT @document_template = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Document Template'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Logistics Document Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label = 'Deal Template',
		clm1_udf_id = @deal_template,
		clm2_label = 'Commodity',
		clm2_udf_id = @commodity,
		clm3_label = 'Origin',
		clm3_udf_id = @origin,
		clm4_label = 'Deal Type',
		clm4_udf_id = @deal_type,
		clm5_label = 'Deal Sub-Type',
		clm5_udf_id = @deal_sub_type,
		clm6_label = 'Buy Inco Terms',
		clm6_udf_id = @buy_inco_term,
		clm7_label = 'Sell Inco Terms',
		clm7_udf_id = @sell_inco_term,
		clm8_label = 'Buy Payments Terms',
		clm8_udf_id = @buy_payments_term,
		clm9_label = 'Sell Payments Terms',
		clm9_udf_id = @sell_payments_term,
		clm10_label = 'Scheduling/Ticket',
		clm10_udf_id = @scheduling_ticket,
		clm11_label = 'Document Category',
		clm11_udf_id = @document_category,
		clm12_label = 'Document Template',
		clm12_udf_id = @document_template,
		required_columns_index = '10,11,12',
		unique_columns_index = '1,2,3,4,5,6,7,8,9,10,11,12'
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Logistics Document Mapping'
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
		required_columns_index,
		unique_columns_index
	)
	SELECT 
		mapping_table_id,
		'Deal Template', @deal_template,
		'Commodity', @commodity,
		'Origin', @origin,
		'Deal Type',@deal_type,
		'Deal Sub-Type', @deal_sub_type,
		'Buy Inco Terms', @buy_inco_term,
		'Sell Inco Terms', @sell_inco_term,
		'Buy Payments Terms', @buy_payments_term,
		'Sell Payments Terms', @sell_payments_term,
		'Scheduling/Ticket', @scheduling_ticket,
		'Document Category', @document_category,
		'Document Template', @document_template,
		'10,11,12',
		'1,2,3,4,5,6,7,8,9,10,11,12'
	FROM generic_mapping_header 
	WHERE mapping_name = 'Logistics Document Mapping'
END

