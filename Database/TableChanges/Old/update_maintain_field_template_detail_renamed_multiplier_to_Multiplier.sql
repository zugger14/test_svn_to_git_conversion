
IF EXISTS (SELECT 1 FROM maintain_field_template_detail WHERE field_caption = 'multiplier')
BEGIN
	UPDATE maintain_field_template_detail SET field_caption = 'Multiplier' WHERE field_caption = 'multiplier'
END


