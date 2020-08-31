SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000345)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (5500, -10000345, 'Storage Contract', 'Storage Contract', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000345 - Storage Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000345 - Storage Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


------------------- Insert UDFs
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_name = -10000345)
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT -10000345,'Storage Contract','d','NVARCHAR(250)','n','EXEC spa_contract_group @flag = ''2''','h',NULL,-10000345
END 
ELSE 
	PRINT '-10000345 Already Exists'

--38404 -> sdv type Storage



