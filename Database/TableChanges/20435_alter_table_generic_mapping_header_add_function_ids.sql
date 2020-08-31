IF COL_LENGTH('generic_mapping_header', 'function_ids') IS NULL
BEGIN
    ALTER TABLE generic_mapping_header ADD function_ids VARCHAR(500) NULL
END
GO

