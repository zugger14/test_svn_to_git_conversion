IF COL_LENGTH('ixp_import_data_source', 'excel_sheet') IS NULL
BEGIN
    ALTER TABLE ixp_import_data_source ADD excel_sheet VARCHAR(100)
END

IF COL_LENGTH('ixp_import_relation', 'excel_sheet') IS NULL
BEGIN
    ALTER TABLE ixp_import_relation ADD excel_sheet VARCHAR(100)
END