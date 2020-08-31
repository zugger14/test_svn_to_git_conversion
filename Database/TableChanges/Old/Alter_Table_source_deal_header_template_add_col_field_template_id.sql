IF COL_LENGTH('source_deal_header_template', 'field_template_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD field_template_id INT NULL
	PRINT 'Column source_deal_header_template.field_template_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.field_template_id already exists.'
END
GO