IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Convert UOM')
BEGIN
 INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
 SELECT  '-5656', 'Convert UOM', 'd', 'int', 'n'
   , 'select source_uom_id,uom_id from source_uom'
   , 'd', NULL, 120, '-5656'
END
ELSE
BEGIN
 PRINT 'print data already exists'
END



IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM Conversion')
BEGIN
 INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
 SELECT  '-5620', 'UOM Conversion', 't', 'VARCHAR(150)', 'n'
   , null
   , 'd', NULL, 120, '-5620'
END
ELSE
BEGIN
 PRINT 'print data already exists'
END






 
IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'UOM Divider')
BEGIN
 INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
 SELECT  '-5633', 'UOM Divider', 't', 'varchar(150)', 'n'
   , null
   , 'd', NULL, 120, '-5633'
END
ELSE
BEGIN
 PRINT 'print data already exists'
END








--SELECT * FROM user_defined_fields_template WHERE field_id='-5620'
--SELECT * FROM user_defined_fields_template WHERE field_id='-5633'


---5633
