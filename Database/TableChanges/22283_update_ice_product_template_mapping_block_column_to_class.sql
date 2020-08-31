IF OBJECT_ID('tempdb..#insert_output_sdv_external') IS NOT NULL
    DROP TABLE #insert_output_sdv_external

CREATE TABLE #insert_output_sdv_external(value_id INT, [type_id] INT , [type_name] VARCHAR(500))

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000275)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000275, 'Class', 'Class', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000275 - Class.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000275 - Class already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--Step 2
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_id = -10000275)
BEGIN
	INSERT INTO user_defined_fields_template(field_name, field_label, Field_type, data_type, is_required, sql_string, udf_type, field_size, field_id)
	SELECT -10000275, 'Class', 'd', 'nvarchar(250)', 'n', 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018', 'h', 100, -10000275
END        

ELSE
BEGIN
    UPDATE user_defined_fields_template
    SET    sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 10018'
    WHERE  Field_label = 'Class'
END
DECLARE @class_id INT
SELECT @class_id=udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Class'

IF EXISTS (SELECT 1 FROM generic_mapping_definition gmd 
			INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmd.mapping_table_id 
           WHERE gmh.mapping_name = 'ICE Product Template Mapping')
BEGIN
	UPDATE gmd
	SET 
		clm6_label = 'Class',
		clm6_udf_id = @class_id
		FROM   generic_mapping_definition gmd
	INNER JOIN generic_mapping_header gmh ON  gmh.mapping_table_id = gmd.mapping_table_id
	WHERE  gmh.mapping_name = 'ICE Product Template Mapping'
END