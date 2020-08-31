IF EXISTS(SELECT 1 FROM user_defined_fields_template WHERE field_label = 'Tier/Class' AND field_type = 'h')
BEGIN
	UPDATE user_defined_fields_template  
	SET field_type = 't' 
	WHERE field_label = 'Tier/Class' 
	AND field_type = 'h'
END