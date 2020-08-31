IF COL_LENGTH('application_version_info', 'version_label_font_size') IS NULL
BEGIN
    ALTER TABLE application_version_info ADD version_label_font_size VARCHAR(50)
END
GO