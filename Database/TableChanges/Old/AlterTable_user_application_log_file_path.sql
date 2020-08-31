IF COL_LENGTH('user_application_log', 'file_path') IS NULL
BEGIN
    ALTER TABLE user_application_log ADD file_path VARCHAR(2000)
END
GO