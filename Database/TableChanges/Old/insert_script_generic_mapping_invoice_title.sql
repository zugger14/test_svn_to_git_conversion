IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
    
CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))   
 
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
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Deal Type'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Book ID2')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Book ID2', 'Book ID2'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Book ID2'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Invoice Title')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Invoice Title', 'Invoice Title'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Invoice Title'
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Invoice Subject')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Invoice Subject', 'Invoice Subject'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Invoice Subject'
END


IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Deal Type'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Deal Type',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_deal_type_id, source_deal_type_name FROM source_deal_type sdt WHERE  (sdt.sub_type IS NULL OR  sdt.sub_type <> ''y'') AND sdt.source_system_id = 2 ORDER BY source_deal_type_name',
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
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_deal_type_id, source_deal_type_name FROM source_deal_type sdt WHERE  (sdt.sub_type IS NULL OR  sdt.sub_type <> ''y'') AND sdt.source_system_id = 2 ORDER BY source_deal_type_name'
    WHERE  Field_label = 'Deal Type'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Book ID2'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Book ID2',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 51 ORDER BY source_book_name',
           'h',
           NULL,
           30,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Book ID2'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT source_book_id, source_book_name FROM source_book WHERE source_system_book_type_value_id = 51 ORDER BY source_book_name'
    WHERE  Field_label = 'Book ID2'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Invoice Title'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Invoice Title',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Invoice Title'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't',
           field_size = 200
    WHERE  Field_label = 'Invoice Title'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Invoice Subject'
   )
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
    SELECT iose.value_id,
           'Invoice Subject',
           'm',
           'VARCHAR(500)',
           'n',
           '',
           'h',
           NULL,
           200,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Invoice Subject'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'm'
    WHERE  Field_label = 'Invoice Subject'
END



DECLARE @deal_type_id INT
DECLARE @book_id2 INT
DECLARE @invoice_title_id INT
DECLARE @invoice_subject_id INT

SELECT @deal_type_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Deal Type'

SELECT @book_id2 = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Book ID2'

SELECT @invoice_title_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Invoice Title'

SELECT @invoice_subject_id = udf_template_id
FROM   user_defined_fields_template
WHERE  Field_label = 'Invoice Subject'

IF NOT EXISTS(SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Invoice Title')
BEGIN
	DECLARE @new_table_id INT
	INSERT INTO generic_mapping_header (mapping_name, total_columns_used) VALUES ('Invoice Title', 4)
	
	SET @new_table_id = SCOPE_IDENTITY()
	
	INSERT INTO generic_mapping_definition (mapping_table_id, clm1_label, clm1_udf_id, clm2_label, clm2_udf_id, clm3_label, clm3_udf_id, clm4_label, clm4_udf_id)
	SELECT @new_table_id, 'Deal Type', @deal_type_id, 'Book ID2', @book_id2, 'Invoice Title', @invoice_title_id, 'Invoice Subject', @invoice_subject_id
END   