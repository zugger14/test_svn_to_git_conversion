IF COL_LENGTH('contract_charge_type_detail', 'default_gl_code_cash_applied') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD default_gl_code_cash_applied INT NULL
END
GO