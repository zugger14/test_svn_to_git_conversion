IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external
 
CREATE TABLE #insert_output_sdv_external
 
(
      value_id     INT,
      [type_id]    INT,
      [type_name]  VARCHAR(500)
)


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'File Column Name' AND type_id = 5500)
BEGIN
	INSERT INTO static_data_value (type_id
								, code
								, description)
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
        INTO #insert_output_sdv_external
	SELECT 5500, 'File Column Name', 'File Column Name'
END
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500
           AND [code] = 'File Column Name'
END 

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'Account Name' AND type_id = 5500)
BEGIN
	INSERT INTO static_data_value (type_id
									, code
									, description) 
		OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT 5500, 'Account Name', 'Account Name'
END 
ELSE
BEGIN
    INSERT INTO #insert_output_sdv_external
    SELECT value_id,
           [type_id],
           code
    FROM static_data_value
    WHERE [type_id] = 5500
           AND [code] = 'Account Name'
END 



--insert udf
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'File Column Name')
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'File Column Name',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'File Column Name'
END


IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Account Name')
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
        SEQUENCE,
        field_size,
        field_id
      )
    SELECT iose.value_id,
           'Account Name',
           't',
           'VARCHAR(150)',
           'n',
           '',
           'h',
           NULL,
           30,
           iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Account Name'
END

--generic_mapping_header
IF NOT EXISTS (SELECT 1 FROM generic_mapping_header WHERE mapping_name = 'Map GL Code')
BEGIN 
	INSERT INTO generic_mapping_header(mapping_name, total_columns_used)
	SELECT 'Map GL Code', 2
END 


--generic_mapping_definatoin
DECLARE @file_column_name INT
DECLARE @account_name INT
SELECT @file_column_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'File Column Name'
SELECT @account_name = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Account Name'
IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id
			WHERE gmh.mapping_name = 'Map GL Code')
BEGIN
    UPDATE gmd
    SET clm1_label = 'File Column Name',  
           clm1_udf_id = @file_column_name, 
           clm2_label = 'Account Name',
           gmd.clm2_udf_id = @account_name
    FROM generic_mapping_definition gmd
           INNER JOIN generic_mapping_header gmh
                ON  gmh.mapping_table_id = gmd.mapping_table_id
    WHERE  gmh.mapping_name = 'Map GL Code'
END
ELSE
BEGIN
    INSERT INTO generic_mapping_definition
      (
        mapping_table_id,
        clm1_label,
        clm1_udf_id,
        clm2_label,
        clm2_udf_id
      )
    SELECT mapping_table_id,
           'File Column Name',
           @file_column_name,
           'Account Name',
           @account_name
    FROM generic_mapping_header
    WHERE mapping_name = 'Map GL Code'
END