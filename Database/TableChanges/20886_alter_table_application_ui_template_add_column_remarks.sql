IF COL_LENGTH('application_ui_template', 'remarks') IS NULL
BEGIN
    ALTER TABLE application_ui_template ADD remarks VARCHAR(250)
END