IF COL_LENGTH('maintain_field_template_detail', 'detail_group_id') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD detail_group_id INT NULL REFERENCES maintain_field_template_group_detail(group_id)
END
GO