IF COL_LENGTH('contract_charge_type_detail', 'deal_type') IS NULL
BEGIN
    ALTER TABLE contract_charge_type_detail ADD deal_type INT NULL
END
ELSE
BEGIN
    PRINT 'deal_type Already Exists.'
END