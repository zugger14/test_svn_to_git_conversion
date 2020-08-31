IF COL_LENGTH('application_ui_template_fields', 'enable_single_select') IS NULL
BEGIN
    ALTER TABLE application_ui_template_fields ADD enable_single_select CHAR(1)
END
GO