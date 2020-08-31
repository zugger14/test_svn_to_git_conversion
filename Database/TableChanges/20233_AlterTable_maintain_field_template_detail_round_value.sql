IF COL_LENGTH('maintain_field_template_detail', 'round_value') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD round_value INT
END
GO