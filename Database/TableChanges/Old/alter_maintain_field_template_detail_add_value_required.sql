IF COL_LENGTH('maintain_field_template_detail', 'value_required') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD value_required CHAR(1)
END
GO




