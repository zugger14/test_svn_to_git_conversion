IF COL_LENGTH('contract_component_mapping', 'time_of_use') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD time_of_use INT NULL
END
GO

IF COL_LENGTH('contract_component_mapping', 'book_identifier1') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD book_identifier1 INT NULL
END
GO

IF COL_LENGTH('contract_component_mapping', 'book_identifier2') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD book_identifier2 INT NULL
END
GO

IF COL_LENGTH('contract_component_mapping', 'book_identifier3') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD book_identifier3 INT NULL
END
GO

IF COL_LENGTH('contract_component_mapping', 'book_identifier4') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD book_identifier4 INT NULL
END
GO

IF COL_LENGTH('contract_component_mapping', 'show_volume') IS NULL
BEGIN
    ALTER TABLE contract_component_mapping ADD show_volume CHAR(1) NULL
END
GO
