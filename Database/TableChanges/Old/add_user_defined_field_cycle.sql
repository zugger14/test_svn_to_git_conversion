IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 5500 AND code = 'Cycle')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	OUTPUT INSERTED.value_id, INSERTED.[type_id], INSERTED.code
	INTO #insert_output_sdv_external
	SELECT '5500', 'Cycle', 'Cycle'
END
ELSE 
BEGIN
	INSERT INTO #insert_output_sdv_external
	SELECT value_id, [type_id], code
	FROM static_data_value WHERE [type_id] = 5500 AND [code] = 'Cycle'
END

IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Cycle'
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
           'Cycle',
           'd',
           'VARCHAR(150)',
           'n',
           'SELECT 1 AS [id], ''1'' [name] UNION ALL   SELECT 2, ''2'' UNION ALL  SELECT 3, ''3'' UNION ALL  SELECT 4, ''4'' UNION ALL  SELECT 5, ''5''',
           'h',
           NULL,
           30,
           iose.value_id
    FROM #insert_output_sdv_external iose
    WHERE iose.[type_name] = 'Cycle'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    Field_type = 'd',
		   sql_string = 'SELECT 1 AS [id], ''1'' [name] UNION ALL   SELECT 2, ''2'' UNION ALL  SELECT 3, ''3'' UNION ALL  SELECT 4, ''4'' UNION ALL  SELECT 5, ''5'''
    WHERE  Field_label = 'Cycle'
END

