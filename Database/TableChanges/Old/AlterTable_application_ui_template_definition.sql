IF COL_LENGTH('application_ui_template_definition', 'is_unique') IS NULL
BEGIN
    ALTER TABLE application_ui_template_definition ADD is_unique CHAR(1)
END
GO

