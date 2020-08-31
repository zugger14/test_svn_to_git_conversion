IF COL_LENGTH('contract_group', 'source_system_id') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN source_system_id INT 
END
GO