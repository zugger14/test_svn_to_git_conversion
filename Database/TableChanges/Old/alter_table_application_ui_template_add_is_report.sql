IF COL_LENGTH('application_ui_template', 'is_report') IS NULL
BEGIN
    ALTER TABLE application_ui_template ADD is_report CHAR(1)
END