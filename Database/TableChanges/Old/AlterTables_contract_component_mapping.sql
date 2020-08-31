IF COL_LENGTH('contract_component_mapping', 'formula_id') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping Add formula_id INT
END
GO

