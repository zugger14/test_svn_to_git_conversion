IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [name] VARCHAR(500))

INSERT INTO #insert_output_sdv_external
SELECT value_id, [type_id], code
FROM static_data_value WHERE value_id = -5733

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Packaging UOM'
   )
BEGIN
	INSERT INTO user_defined_fields_template (
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
           'Packaging UOM',
           'd',
           'INT',
           'n',
           'EXEC [spa_source_uom_maintain] ''s''',
           'd',
           NULL,
           180,
           iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[name] = 'Packaging UOM'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'EXEC [spa_source_uom_maintain] ''s'''
    WHERE  Field_label = 'Packaging UOM'
END