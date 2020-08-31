IF COL_LENGTH('contract_group_detail', 'include_invoice') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD include_invoice CHAR(1)
END
GO