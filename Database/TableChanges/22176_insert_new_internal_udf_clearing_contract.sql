/* Adding Static Data */
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000261)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000261, 'Clearing Contract', 'Clearing Contract', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000261 - Clearing Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000261 - Clearing Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

/* Adding UDF field in UDF template */
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000261)
BEGIN
    INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, [sequence], field_size, field_id)
    SELECT -10000261, 'Clearing Contract', 'd', 'INT', 'n', 'EXEC spa_contract_group @flag = ''m''', 'h', NULL, NULL, -10000261
END
ELSE
BEGIN
    PRINT 'user_defined_fields_template -10000261 - Clearing Contract already EXISTS.'
END

GO