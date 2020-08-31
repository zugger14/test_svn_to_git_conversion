IF COL_LENGTH('application_ui_template', 'template_type') IS NULL
BEGIN
    ALTER TABLE application_ui_template ADD template_type INT
END