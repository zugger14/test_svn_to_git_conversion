IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE default_label = 'Excersice Type')
BEGIN
	UPDATE maintain_field_deal SET default_label = 'Exercise Type' WHERE default_label = 'Excersice Type'
END

IF EXISTS (SELECT 1 FROM maintain_field_template_detail WHERE field_caption = 'Excersice Type')
BEGIN
	UPDATE maintain_field_template_detail SET field_caption = 'Exercise Type' WHERE field_caption = 'Excersice Type'
END

IF EXISTS (SELECT 1 FROM maintain_field_template_detail WHERE field_caption = 'Excercise Type')
BEGIN
	UPDATE maintain_field_template_detail SET field_caption = 'Exercise Type' WHERE field_caption = 'Excercise Type'
END
