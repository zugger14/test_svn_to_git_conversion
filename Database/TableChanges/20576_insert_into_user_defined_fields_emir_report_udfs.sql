IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Intragroup')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000036, 'Intragroup', 't', 'VARCHAR(150)', 'n', 'SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''NO''', 'h', NULL, 180, -10000036
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Clearing Timestamp')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000035, 'Clearing Timestamp', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 180, -10000035
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Cleared')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000034, 'Cleared', 'd', 'VARCHAR(150)', 'n', 'SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''', 'h', NULL, 180, -10000034
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Clearing Obligation')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000033, 'Clearing Obligation', 'd', 'VARCHAR(150)', 'n', 'SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''', 'h', NULL, 180, -10000033
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Confirmation Timestamp')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000032, 'Confirmation Timestamp', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 180, -10000032
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Execution Timestamp')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000031, 'Execution Timestamp', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 180, -10000031
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Venue of Execution')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000030, 'Venue of Execution', 'd', 'VARCHAR(150)', 'n', 'SELECT clm3_value, clm6_value FROM generic_mapping_values gmv INNER JOIN generic_mapping_header gmh ON gmh.mapping_table_id = gmv.mapping_table_id AND gmh.mapping_name = ''MIC List''', 'h', NULL, 180, -10000030
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'	

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Global UTI')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000029, 'Global UTI', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 180, -10000029
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Product Classification')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000028, 'Product Classification', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 180, -10000028
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Product Classification Type')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000027, 'Product Classification Type', 'd', 'VARCHAR(150)', 'n', 'SELECT ''C'' id, ''CFI'' code UNION ALL SELECT ''U'', ''UPI''', 'h', NULL, 180, -10000027
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Asset Class')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000026, 'Asset Class', 'd', 'VARCHAR(150)', 'n', 'SELECT ''CO'' id, ''Commodity and Emission Allowances '' code UNION ALL SELECT ''CR'', ''Credit'' UNION ALL SELECT ''CU'', ''Currency'' UNION ALL SELECT ''EQ'', ''Equity'' UNION ALL SELECT ''IR'', ''Interest Rate''', 'h', NULL, 180, -10000026
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'
GO

IF NOT EXISTS (SELECT 1 FROM user_defined_fields_template WHERE Field_label = 'Collateralization')
BEGIN
	INSERT INTO user_defined_fields_template (field_name, Field_label, Field_type, data_type, is_required, sql_string, udf_type, sequence, field_size, field_id)
	SELECT -10000025, 'Collateralization', 't', 'VARCHAR(150)', 'n', NULL, 'h', NULL, 400, -10000025
	PRINT 'UDF Created.'
END
ELSE
	PRINT 'UDF aleady exists.'