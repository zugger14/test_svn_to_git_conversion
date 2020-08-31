IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'ICE Product')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'ICE Product', 'ICE Product'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'ICE Product'
END

--step 2
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'ICE Product'
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
           'ICE Product',
           't',
           'VARCHAR(100)',
           'y',
           NULL,
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'ICE Product'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = ''
    WHERE  Field_label = 'ICE Product'
END

DECLARE @ice_product_id INT, @sub_book INT

SELECT @ice_product_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'ICE Product'
SELECT @sub_book=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Sub Book'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Book Mapping')

BEGIN
	UPDATE gmd
	SET 
		clm3_label = 'ICE Product',
		clm3_udf_id = @ice_product_id,
		clm4_label = 'Sub Book',
		clm4_udf_id = @sub_book,
		clm5_label = NULL,
		clm5_udf_id = NULL,
		clm6_label = NULL,
		clm6_udf_id = NULL
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'ICE Book Mapping'
END

UPDATE gmh SET gmh.total_columns_used = 4
-- SELECT gmh.*
FROM generic_mapping_header gmh
WHERE gmh.mapping_name = 'ICE Book Mapping'