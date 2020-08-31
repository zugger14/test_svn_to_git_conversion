IF COL_LENGTH('contract_group_detail', 'default_gl_code_cash_applied') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD default_gl_code_cash_applied INT NULL
END
GO