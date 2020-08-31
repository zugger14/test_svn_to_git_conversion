IF COL_LENGTH('application_ui_template_fields', 'dependent_field') IS NULL
BEGIN
    ALTER TABLE application_ui_template_fields ADD dependent_field VARCHAR(200)
END
GO


IF COL_LENGTH('application_ui_template_fields', 'dependent_query') IS NULL
BEGIN
    ALTER TABLE application_ui_template_fields ADD dependent_query VARCHAR(200)
END
GO