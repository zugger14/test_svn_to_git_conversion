IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'EEA')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000020','EEA','d','VARCHAR(150)','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''','h',400,-10000020
END 
ELSE 
	PRINT 'Already Exists'