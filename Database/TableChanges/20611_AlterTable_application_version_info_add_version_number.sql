IF COL_LENGTH('application_version_info', 'version_number') IS NULL
BEGIN
    ALTER TABLE application_version_info ADD version_number VARCHAR(50)
END
GO