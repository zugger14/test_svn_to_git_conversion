IF COL_LENGTH('process_table_archive_policy', 'fieldlist') IS NOT NULL
BEGIN
    ALTER TABLE process_table_archive_policy ALTER COLUMN fieldlist VARCHAR(8000)
END
GO