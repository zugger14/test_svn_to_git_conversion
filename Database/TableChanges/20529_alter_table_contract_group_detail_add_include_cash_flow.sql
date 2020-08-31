IF COL_LENGTH('contract_group_detail', 'include_cash_flow') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD include_cash_flow CHAR(1)
END
ELSE
BEGIN
    PRINT 'include_cash_flow Already Exists.'
END

IF COL_LENGTH('contract_charge_type_detail', 'include_cash_flow') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD include_cash_flow CHAR(1)
END
ELSE
BEGIN
    PRINT 'include_cash_flow Already Exists.'
END