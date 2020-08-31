IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5615)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'ACER Code'  WHERE field_name = -5615
END

IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE field_name = -5616)
BEGIN
	UPDATE user_defined_fields_template SET Field_label = 'ACER Code Type'  WHERE field_name = -5616
END