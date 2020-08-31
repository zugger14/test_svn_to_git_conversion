
IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'CSA Reportable Trade')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-5743','CSA Reportable Trade','d','VARCHAR(150)','y','SELECT ''Y'' id, ''Y'' value UNION ALL SELECT ''N'' id, ''N'' value ORDER BY value','h',180,-5743
END 
ELSE 
	PRINT 'Already Exists'

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Financial/Non-Financial')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000019','Financial/Non-Financial','d','VARCHAR(150)','n','SELECT ''F'' id, ''Financial'' code UNION ALL SELECT ''N'', ''Non-Financial''','h',400,-10000019
END 
ELSE 
	PRINT 'Already Exists'

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Commercial/Treasury')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000021','Commercial/Treasury','d','VARCHAR(150)','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''','h',400,-10000021
END 
ELSE 
	PRINT 'Already Exists'
