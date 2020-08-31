IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

--step 2

-- Trader ID --
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Trader ID'
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
           'Trader ID',
           'd',
           'VARCHAR(100)',
           'y',
           'SELECT source_trader_id,trader_name FROM source_traders',
           'h',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Trader ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_trader_id,trader_name FROM source_traders'
    WHERE  Field_label = 'Trader ID'
END

-- Index ID --
IF NOT EXISTS (
       SELECT 1
       FROM   user_defined_fields_template
       WHERE  Field_label = 'Index ID'
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
           'Index ID',
           'd',
           'VARCHAR(100)',
           'y',
           'SELECT source_curve_def_id,curve_name FROM source_price_curve_def',
           'h',
           NULL,
           100,
           iose.value_id
    FROM   #insert_output_sdv_external iose
    WHERE  iose.[type_name] = 'Index ID'
END
ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'SELECT source_curve_def_id,curve_name FROM source_price_curve_def'
    WHERE  Field_label = 'Index ID'
END