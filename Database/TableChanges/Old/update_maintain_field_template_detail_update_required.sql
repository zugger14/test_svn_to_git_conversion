UPDATE maintain_field_template_detail SET update_required = insert_required 

UPDATE maintain_field_template_detail SET	update_required = 'y' WHERE insert_required = 'n' AND hide_control = 'n'

UPDATE maintain_field_template_detail SET	update_required = 'n' WHERE hide_control = 'y'
