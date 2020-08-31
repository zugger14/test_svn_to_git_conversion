IF COL_LENGTH('application_ui_filter_details', 'field_value') IS NOT NULL
BEGIN
    ALTER TABLE application_ui_filter_details ALTER COLUMN field_value VARCHAR(1000)
END
GO


