IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [name] VARCHAR(500))

INSERT INTO #insert_output_sdv_external
SELECT value_id, [type_id], code
FROM static_data_value WHERE value_id = -5732

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Package#'
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
           'Package#',
           't',
           'VARCHAR(150)',
           'n',
           NULL,
           'd',
           NULL,
           180,
           iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[name] = 'Package#'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 't'
    WHERE  Field_label = 'Package#'
END