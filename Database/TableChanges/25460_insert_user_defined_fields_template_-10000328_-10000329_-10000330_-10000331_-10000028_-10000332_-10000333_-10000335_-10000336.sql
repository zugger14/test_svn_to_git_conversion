IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'VOICE DEAL')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000328','VOICE DEAL','d','NVARCHAR(250)','n','SELECT ''t'' id, ''True'' code UNION ALL SELECT ''f'', ''False''','h',180,-10000328
END 
ELSE 
	PRINT '-10000328 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Initiator/Aggressor')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000329','Initiator/Aggressor','d','NVARCHAR(250)','n','SELECT ''Y'' id, ''Yes'' code UNION ALL SELECT ''N'', ''No''','h',180,-10000329
END 
ELSE 
	PRINT '-10000329 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'EXECUTION VENUE ID')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000330','EXECUTION VENUE ID','t','NVARCHAR(250)','n','','h',180,-10000330
END 
ELSE 
	PRINT '-10000330 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'TRADING CAPACITY')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000331','TRADING CAPACITY','t','NVARCHAR(250)','n','','h',180,-10000331
END 
ELSE 
	PRINT '-10000331 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'PRODUCT CLASSIFICATION')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000028','PRODUCT CLASSIFICATION','t','NVARCHAR(250)','n','','h',180,-10000028
END 
ELSE 
	PRINT '-10000028 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'FOREIGN CONTRACT ID')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000332','FOREIGN CONTRACT ID','t','NVARCHAR(250)','n','','h',180,-10000332
END 
ELSE 
	PRINT '-10000332 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Counterparty Trader')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000333','Counterparty Trader','t','NVARCHAR(250)','n','','h',180,-10000333
END 
ELSE 
	PRINT '-10000333 Already Exists'

IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Sleeve')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000335','Sleeve','d','NVARCHAR(250)','n','SELECT ''y'' id, ''Yes'' code UNION ALL SELECT ''n'', ''No''','h',180,-10000335
END 
ELSE 
	PRINT '-10000335 Already Exists'


IF NOT EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Spread')
BEGIN
	INSERT INTO user_defined_fields_template(field_name,field_label,field_type,data_type,is_required,sql_string,udf_type,field_size,field_id)
	SELECT '-10000336','Spread','d','NVARCHAR(250)','n','SELECT ''y'' id, ''Yes'' code UNION ALL SELECT ''n'', ''No''','h',180,-10000336
END 
ELSE 
	PRINT '-10000336 Already Exists'

	