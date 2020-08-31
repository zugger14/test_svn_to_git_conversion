IF COL_LENGTH('user_defined_tables_metadata', 'custom_sql') IS NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ADD custom_sql VARCHAR(5000) NULL
END
GO
