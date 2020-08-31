IF COL_LENGTH('virtual_storage_constraint', 'value') IS NOT NULL
BEGIN
    ALTER TABLE virtual_storage_constraint ALTER COLUMN value BIGINT
END
GO