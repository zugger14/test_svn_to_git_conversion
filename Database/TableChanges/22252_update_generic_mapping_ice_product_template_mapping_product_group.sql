IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Product Group')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
		INTO #insert_output_sdv_external
	SELECT '5500', 'Product Group', 'Product Group'
END
ELSE 
BEGIN
	INSERT INTO  #insert_output_sdv_external
	SELECT value_id, [type_id], code
	  FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Product Group'
END

--Step 2
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
           'nvarchar(250)',
           'n',
           'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800',
           'h',
           NULL,
           NULL,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Product Group'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 39800'
    WHERE  Field_label = 'Product Group'
END
DECLARE @product_group INT
SELECT @product_group=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Product Group'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Product Template Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm4_label = 'Product Group',
		clm4_udf_id = @product_group
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'ICE Product Template Mapping'
END

UPDATE gmh SET gmh.total_columns_used = 6
-- SELECT gmh.*
FROM generic_mapping_header gmh
WHERE gmh.mapping_name ='ICE Product Template Mapping'
/*
select * from generic_mapping_header where mapping_name = 'ICE Product Template Mapping'
select * from generic_mapping_definition where  mapping_table_id = 135
SELECT * FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Product Template Mapping'
	select * from dbo.generic_mapping_values where mapping_table_id = 135
*/