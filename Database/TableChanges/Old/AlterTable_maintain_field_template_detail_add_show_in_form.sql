IF COL_LENGTH('maintain_field_template_detail', 'show_in_form') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD show_in_form CHAR(1)
END
GO

UPDATE maintain_field_template_detail
SET show_in_form = 'n'
WHERE show_in_form IS NULL