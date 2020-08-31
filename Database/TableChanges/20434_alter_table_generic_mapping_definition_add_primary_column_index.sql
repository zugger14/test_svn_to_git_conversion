IF COL_LENGTH('generic_mapping_definition', 'primary_column_index') IS NULL
BEGIN
    ALTER TABLE generic_mapping_definition ADD primary_column_index VARCHAR(100) NULL
END
GO