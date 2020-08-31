IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [name] VARCHAR(500), header_detail CHAR(1))

INSERT INTO #insert_output_sdv_external
SELECT value_id, [type_id], code, CASE WHEN value_id < -5736 THEN 'd' ELSE 'h' END
FROM static_data_value WHERE value_id BETWEEN -5739 AND -5734

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
        iose.[name] ,
        't',
        'VARCHAR(150)',
        'n',
        NULL,
        iose.header_detail,
        NULL,
        180,
        iose.value_id
FROM #insert_output_sdv_external iose
LEFT JOIN user_defined_fields_template udft ON udft.field_name = iose.value_id    
WHERE udft.udf_template_id IS NULL