IF COL_LENGTH('contract_charge_type_detail', 'alias') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD alias INT
END
GO