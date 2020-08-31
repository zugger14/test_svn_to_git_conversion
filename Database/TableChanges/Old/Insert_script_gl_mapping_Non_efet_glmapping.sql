DELETE gmv FROM generic_mapping_header gmh INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id 
WHERE gmh.mapping_name = 'Non EFET SAP GL Mapping'

DELETE gmd FROM generic_mapping_header gmh INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id 
WHERE gmh.mapping_name = 'Non EFET SAP GL Mapping'

DELETE FROM generic_mapping_header  WHERE mapping_name = 'Non EFET SAP GL Mapping'

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

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Sub Process')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Sub Process', 'Sub Process'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Sub Process'
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


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Country')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Country', 'Country'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Country'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Entity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Entity', 'Entity'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Entity'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'GSP Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'GSP Group', 'GSP Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'GSP group'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Product group', 'Product group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Product group'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Products')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Products', 'Products'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Products'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year General Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year General Ledger', 'Current Year General Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year General Ledger'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year Cost Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year Cost Center', 'Current Year Cost Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year Cost Center'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year Profit Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year Profit Center', 'Current Year Profit Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year Profit Center'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Current Year Balance Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Current Year Balance Ledger', 'Current Year Balance Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Current Year Balance Ledger'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year General Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year General Ledger', 'Last Year General Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year General Ledger'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year Cost Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year Cost Center', 'Last Year Cost Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year Cost Center'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year Profit Center')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year Profit Center', 'Last Year Profit Center'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year Profit Center'
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Last Year Balance Ledger')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Last Year Balance Ledger', 'Last Year Balance Ledger'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Last Year Balance Ledger'
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
       WHERE  Field_label = 'Sub Process'
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
           'Sub Process',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT ''i'' as ID, ''Inbound'' name
			 UNION ALL 
		   SELECT  ''o'' as ID, ''Outbound'' name 
			UNION ALL 
			SELECT ''s'' as ID, ''Self-Billing'' name
		   ',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Sub Process'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = '	SELECT ''i'' as ID,''Inbound'' name
							UNION ALL 
							SELECT  ''o'' as ID, ''Outbound'' name 
							UNION ALL 
							SELECT ''s'' as ID, ''Self-Billing'' name'
    WHERE  Field_label = 'Sub Process'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Country'
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
           'Country',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_Data_value where type_id = 14000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Country'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select  value_id,code FROM static_Data_value where type_id = 14000'
    WHERE  Field_label = 'Country'
END



IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Entity'
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
           'Entity',
           'd',
           'VARCHAR(150)',
           'n',
           '
SELECT sc.source_counterparty_id
				,sc.counterparty_name

			FROM counterparty_epa_account cea
			INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
				AND sdt_cea.type_name = ''Counterparty External ID''
			INNER JOIN source_counterparty sc ON 
			 cea.counterparty_id =  sc.source_counterparty_id
			 WHERE 
				 cea.external_type_id = sdv_cea.value_id
				AND sdv_cea.code = ''Entity Code''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Entity'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = '
SELECT sc.source_counterparty_id
				,sc.counterparty_name

			FROM counterparty_epa_account cea
			INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
				AND sdt_cea.type_name = ''Counterparty External ID''
			INNER JOIN source_counterparty sc ON 
			 cea.counterparty_id =  sc.source_counterparty_id
			 WHERE 
				 cea.external_type_id = sdv_cea.value_id
				AND sdv_cea.code = ''Entity Code'''
    WHERE  Field_label = 'Entity'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Product Group'
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
           'Product Group',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =27000',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =27000'
    WHERE  Field_label = 'Product Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'GSP Group'
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
           'GSP Group',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GSP group''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'GSP Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GSP group'''
    WHERE  Field_label = 'GSP Group'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Products'
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
           'Products',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10019',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Products'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10019'
    WHERE  Field_label = 'Products'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year General Ledger'
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
           'Current Year General Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year General Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29800'
    WHERE  Field_label = 'Current Year General Ledger'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year Balance Ledger'
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
           'Current Year Balance Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GL Account Balance For Estimate''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year Balance Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GL Account Balance For Estimate'''
    WHERE  Field_label = 'Current Year Balance Ledger'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year Cost Center'
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
           'Current Year Cost Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10005',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year Cost Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10005'
    WHERE  Field_label = 'Current Year Cost Center'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Current Year Profit Center'
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
           'Current Year Profit Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29900',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Current Year Profit Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29900'
    WHERE  Field_label = 'Current Year Profit Center'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year General Ledger'
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
           'Last Year General Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29800',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year General Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29800'
    WHERE  Field_label = 'Last Year General Ledger'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year Balance Ledger'
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
           'Last Year Balance Ledger',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GL Account Balance For Estimate''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year Balance Ledger'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code from static_data_type sdt  INNER JOIN static_data_value sdv ON sdt.type_id = sdv.type_id where type_name = ''GL Account Balance For Estimate'''
    WHERE  Field_label = 'Last Year Balance Ledger'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year Cost Center'
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
           'Last Year Cost Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =10005',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year Cost Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =10005'
    WHERE  Field_label = 'Last Year Cost Center'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Last Year Profit Center'
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
           'Last Year Profit Center',
           'd',
           'VARCHAR(150)',
           'n',
           'Select value_id,code FROM static_data_value where type_id  =29900',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Last Year Profit Center'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'Select value_id,code FROM static_data_value where type_id  =29900'
    WHERE  Field_label = 'Last Year Profit Center'
END

/* Insert Generic Mapping Header */
IF EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Non EFET SAP GL Mapping')
BEGIN
	PRINT 'Mapping Table Already Exists'
END
ELSE 
BEGIN 
	INSERT INTO generic_mapping_header (
	mapping_name,
	total_columns_used
	) VALUES (
	'Non EFET SAP GL Mapping',
	16
	)
END

/*Insert into Generic Mapping Defination*/
DECLARE @Process                      INT
,@Inbound_Outbound            INT
,@Country                     INT
,@Counterparty                INT
,@Product_Group               INT
,@Products                    INT
,@Current_Year_General_Ledger INT
,@Current_Year_Cost_Center    INT
,@Current_Year_Profit_Center  INT
,@Last_Year_General_Ledger    INT
,@Last_Year_Cost_Center       INT
,@Last_Year_Profit_Center     INT 
,@entity INT
,@ic_ext INT 
, @sub_process INT
,@gsp_group INT 
,@current_year_balance_ledger INT
,@last_year_balance_ledger INT 

SELECT @Process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'process'
SELECT @sub_process=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Process'
SELECT @Country=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Country'
SELECT @entity=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Entity'
SELECT @ic_ext  = udf_template_id FROM user_defined_fields_template where field_label = 'IC Ext'
SELECT @gsp_group = udf_template_id FROM user_defined_fields_template where field_label = 'GSP Group'
SELECT @current_year_balance_ledger = udf_template_id FROM user_defined_fields_template where field_label = 'Current Year Balance Ledger' 


SELECT @Product_Group=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'product group'
SELECT @Products=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'products'
SELECT @Current_Year_General_Ledger=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year General Ledger'
SELECT @current_year_cost_center= udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year Cost Center'
SELECT @Current_Year_Profit_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Current Year Profit Center'
SELECT @Last_Year_General_Ledger=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year General Ledger'
SELECT @Last_Year_Cost_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year Cost Center'
SELECT @Last_Year_Profit_Center=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Last Year Profit Center'
SELECT @last_year_balance_ledger = udf_template_id FROM user_defined_fields_template where field_label = 'Last Year Balance Ledger' 



IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'Non EFET SAP GL Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm1_label= 'Process', clm1_udf_id = @Process,
		clm2_label = 'Sub Process', clm2_udf_id =@sub_process  ,
		clm3_label = 'IC EXT',clm3_udf_id = @ic_ext,
		clm4_label = 'Country',clm4_udf_id = @country,
		clm5_label ='Entity', clm5_udf_id = @entity,
		clm6_label = 'GSP Group',clm6_udf_id = @gsp_group,
		clm7_label='Product Group', clm7_udf_id = @product_group,
		clm8_label = 'Products' ,clm8_udf_id = @products,
		clm9_label = 'Current Year General Ledger',clm9_udf_id = @Current_Year_General_Ledger ,
		clm10_label ='Current Year Cost Center', clm10_udf_id= @Current_Year_Cost_Center,
		clm11_label = 'Current Year Profit Center',clm11_udf_id = @Current_Year_Profit_Center,
		clm12_label = 'Current Year Balance Ledger',clm12_udf_id = @current_year_balance_ledger,
		clm13_label ='Last Year General Ledger',
		clm13_udf_id =@Last_Year_General_Ledger ,
		clm14_label = 'Last Year Cost Center',
		clm14_udf_id =@Last_Year_Cost_Center,
		clm15_label= 'Last Year Profit Center',
		clm15_udf_id = @Last_Year_Profit_Center,
		clm16_label = 'Last Year Balance Ledger',
		clm16_udf_id = @last_year_balance_ledger
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'Non EFET SAP GL Mapping'
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
		clm13_label,clm13_udf_id,
		clm14_label,clm14_udf_id,
		clm15_label,clm15_udf_id,
		clm16_label,clm16_udf_id
	)
	SELECT 
		mapping_table_id,
		'Process',@Process,
		'Sub Process',@sub_process  ,
		'IC EXT',@ic_ext,
		'Country',@country,
		'Entity', @entity,
		'GSP Group',@gsp_group,
		'Product Group',@product_group,
		'Products' ,@products,
		'Current Year General Ledger',@Current_Year_General_Ledger ,
		'Current Year Cost Center', @Current_Year_Cost_Center,
		'Current Year Profit Center',@Current_Year_Profit_Center,
		'Current Year Balance Ledger',@current_year_balance_ledger,
		'Last Year General Ledger',@Last_Year_General_Ledger ,
		'Last Year Cost Center',@Last_Year_Cost_Center,
		'Last Year Profit Center',@Last_Year_Profit_Center,
		'Last Year Balance Ledger',@last_year_balance_ledger
	FROM generic_mapping_header 
	WHERE mapping_name = 'Non EFET SAP GL Mapping'
END




