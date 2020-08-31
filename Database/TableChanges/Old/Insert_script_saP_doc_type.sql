IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Process')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Process', 'Process'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Process'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sub_process')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Sub_process', 'Sub_process'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sub_process'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'IC EXT')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'IC EXT', 'IC EXT'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'IC EXT'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'BUY SELL')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'BUY SELL', 'BUY SELL'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'BUY SELL'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Doc Type')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Doc Type', 'Doc Type'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Doc Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TAX')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'TAX', 'TAX'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TAX'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'TAX CODE')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'TAX CODE', 'TAX CODE'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'TAX CODE'
END
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Process'
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
           'Process',
           'd',
           'VARCHAR(150)',
           'n',
           'Select ''i'' as id,''Invoicing'' as name
			UNION ALL
			Select ''a''  as id,''Accrual''  as name',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Process'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select ''i'' as id,''Invoicing'' as name
			UNION ALL
			Select ''a''  as id,''Accrual''  as name'
    WHERE  Field_label = 'Process'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Sub_process'
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
           'Sub_process',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT  ''o'' as ID, ''Outbound'' name 
			UNION ALL 
			SELECT ''s'' as ID, ''Self-Billing'' name
		   ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sub_process'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT  ''o'' as ID, ''Outbound'' name 
							UNION ALL 
							SELECT ''s'' as ID, ''Self-Billing'' name'
    WHERE  Field_label = 'Sub_process'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'IC EXT'
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
           'IC EXT',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''e'' ID, ''external'' value
			UNION 
			SELECT ''i'' ID, ''internal'' value
			UNION 
			SELECT ''b'' ID, ''broker'' value',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'IC EXT'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''e'' ID, ''external'' value
						UNION 
						SELECT ''i'' ID, ''internal'' value
						UNION 
						SELECT ''b'' ID, ''broker'' value'
    WHERE  Field_label = 'IC EXT'
END



IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'BUY SELL'
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
           'BUY SELL',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''b'' ID, ''Buy'' value
			UNION 
			SELECT ''s'' ID, ''Sell'' value',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'BUY SELL'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT ''b'' ID, ''Buy'' value
			UNION 
			SELECT ''s'' ID, ''Sell'' value'
    WHERE  Field_label = 'BUY SELL'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Doc Type'
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
           'Doc Type',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Doc Type'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
		   sql_string = ''
    WHERE  Field_label = 'Doc Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TAX'
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
           'TAX',
           'd',
           'VARCHAR(150)',
           'n',
           'Select source_curve_def_id,curve_id FROm source_price_curve_def',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TAX'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select source_curve_def_id,curve_id FROm source_price_curve_def'
    WHERE  Field_label = 'TAX'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'TAX CODE'
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
           'TAX CODE',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10004',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'TAX CODE'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10004'
    WHERE  Field_label = 'TAX CODE'
END




/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'SAP Doc type')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'SAP Doc type',
	7
	)
END

/*Insert into Generic Mapping Defination*/
DECLARE @Process                      INT
,@sub_process            INT
,@IC_EXT                    INT
,@BUY_SELL                INT
,@doc_type               INT
,@TAX                    INT
,@tax_code INT



SELECT @Process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'process'
SELECT  @sub_process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub_process'
SELECT @IC_EXT=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'IC EXT'
SELECT @BUY_SELL=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'BUY SELL'

SELECT @doc_type=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Doc Type'
SELECT @TAX=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TAX'
SELECT @tax_code=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TAX CODE'



IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'SAP Doc type')
BEGIN
	UPDATE gmd
	SET 
		clm1_label= 'Process',
		 clm1_udf_id = @Process,
		clm2_label = 'Sub process', 
		clm2_udf_id = @sub_process  ,
		clm3_label = 'IC EXT',
		 clm3_udf_id = @IC_EXT,
		clm4_label ='BUY SELL', 
		clm4_udf_id = @BUY_SELL,
		clm5_label='Doc Type', 
		clm5_udf_id = @doc_type,
		clm6_label = 'TAX' ,
		 clm6_udf_id = @TAX,
		clm7_label = 'TAX CODE',
		 clm7_udf_id = @tax_code
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'SAP Doc type'
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
		clm7_label, clm7_udf_id
	)
	SELECT 
		mapping_table_id,
		'Process',@Process,
		'Sub process', @sub_process  ,
		'IC EXT',@IC_EXT,
		'BUY SELL', @BUY_SELL,
		'Doc Type',@doc_type,
		'TAX' ,@TAX,
		'TAX CODE',@tax_code 
	FROM generic_mapping_header 
	WHERE mapping_name = 'SAP Doc type'
END

