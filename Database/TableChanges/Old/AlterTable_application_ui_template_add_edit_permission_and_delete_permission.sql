IF COL_LENGTH('application_ui_template', 'edit_permission') IS NULL
BEGIN
    ALTER TABLE application_ui_template ADD edit_permission VARCHAR(100)
END
GO

IF COL_LENGTH('application_ui_template', 'delete_permission') IS NULL
BEGIN
    ALTER TABLE application_ui_template ADD delete_permission VARCHAR(100)
END
GO