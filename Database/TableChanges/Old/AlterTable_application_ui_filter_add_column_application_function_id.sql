IF COL_LENGTH('application_ui_filter', 'application_function_id') IS NULL
BEGIN
    ALTER TABLE application_ui_filter ADD application_function_id INT NULL
END
GO