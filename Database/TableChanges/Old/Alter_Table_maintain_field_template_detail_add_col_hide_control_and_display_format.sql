IF COL_LENGTH('maintain_field_template_detail', 'hide_control') IS NULL
BEGIN
	ALTER TABLE maintain_field_template_detail ADD hide_control CHAR(1)
	PRINT 'Column maintain_field_template_detail.hide_control added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_field_template_detail.hide_control already exists.'
END

IF COL_LENGTH('maintain_field_template_detail', 'display_format') IS NULL
BEGIN
	ALTER TABLE maintain_field_template_detail ADD display_format INT
	PRINT 'Column maintain_field_template_detail.display_format added.'
END
ELSE
BEGIN
	PRINT 'Column maintain_field_template_detail.display_format already exists.'
END
GO