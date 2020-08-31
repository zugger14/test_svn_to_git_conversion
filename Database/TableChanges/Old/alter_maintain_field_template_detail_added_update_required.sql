IF COL_LENGTH('maintain_field_template_detail', 'update_required') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD update_required CHAR(1)
END
ELSE PRINT 'Field already exists'
GO