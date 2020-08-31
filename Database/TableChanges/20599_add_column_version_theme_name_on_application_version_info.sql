IF COL_LENGTH('application_version_info', 'version_theme_name') IS NULL
BEGIN
    ALTER TABLE application_version_info
	ADD version_theme_name VARCHAR(50)
END