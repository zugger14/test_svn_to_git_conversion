IF COL_LENGTH('generic_mapping_definition', 'unique_columns_index') IS NULL
BEGIN
    ALTER TABLE generic_mapping_definition ADD unique_columns_index VARCHAR(5000)
END

IF COL_LENGTH('generic_mapping_definition', 'required_columns_index') IS NULL
BEGIN
    ALTER TABLE generic_mapping_definition ADD required_columns_index VARCHAR(5000)
END
GO
