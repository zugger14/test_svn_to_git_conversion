IF COL_LENGTH('ixp_import_data_mapping', 'where_clause') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_mapping ADD where_clause VARCHAR(MAX)
END
GO