IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5615)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'ACER' WHERE field_name = -5615
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5620)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'PRP Power' WHERE field_name = -5620
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5621)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'PRP Gas' WHERE field_name = -5621
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5622)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'EAN Power' WHERE field_name = -5622
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5623)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'EAN Gas' WHERE field_name = -5623
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5691)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'BIC' WHERE field_name = -5691
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5693)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'LEI' WHERE field_name = -5693
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5692 )
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'EIC' WHERE field_name = -5692 
END 

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5694 )
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'TSO Gas' WHERE field_name = -5694
END 
