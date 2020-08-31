--Deleting unwanted column which is added recently.
IF COL_LENGTH('contract_charge_type_detail', 'effective_date_general') IS NOT NULL
BEGIN
    ALTER TABLE contract_charge_type_detail DROP COLUMN effective_date_general
END

IF COL_LENGTH('contract_charge_type_detail', 'end_date_general') IS NOT NULL
BEGIN
    ALTER TABLE contract_charge_type_detail DROP COLUMN end_date_general
END

--Adding new column.
IF COL_LENGTH('contract_charge_type_detail', 'end_date') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD end_date DATETIME
END

