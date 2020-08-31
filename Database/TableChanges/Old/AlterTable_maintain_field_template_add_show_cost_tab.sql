IF COL_LENGTH('maintain_field_template', 'show_cost_tab') IS NULL
BEGIN
    ALTER TABLE maintain_field_template ADD show_cost_tab NCHAR(1)
END
GO

IF COL_LENGTH('maintain_field_template', 'show_detail_cost_tab') IS NULL
BEGIN
    ALTER TABLE maintain_field_template ADD show_detail_cost_tab NCHAR(1)
END
GO

IF COL_LENGTH('maintain_field_template_group', 'default_tab') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_group ADD default_tab BIT DEFAULT(0)
END
GO