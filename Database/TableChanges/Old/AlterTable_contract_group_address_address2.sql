IF COL_LENGTH('contract_group', 'address') IS NOT NULL
BEGIN
   ALTER TABLE contract_group
   ALTER COLUMN address VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('contract_group', 'address2') IS NOT NULL
BEGIN
   ALTER TABLE contract_group
   ALTER COLUMN address2 VARCHAR(MAX)
    
END
GO

IF COL_LENGTH('contract_group_audit', 'address') IS NOT NULL
BEGIN
   ALTER TABLE contract_group_audit
   ALTER COLUMN address VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('contract_group_audit', 'address2') IS NOT NULL
BEGIN
   ALTER TABLE contract_group_audit
   ALTER COLUMN address2 VARCHAR(MAX)
    
END
GO

--------

IF COL_LENGTH('source_counterparty', 'contact_address') IS NOT NULL
BEGIN
   ALTER TABLE source_counterparty
   ALTER COLUMN contact_address VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('source_counterparty', 'contact_address2') IS NOT NULL
BEGIN
   ALTER TABLE source_counterparty
   ALTER COLUMN contact_address2 VARCHAR(MAX)
    
END
GO

IF COL_LENGTH('source_counterparty_audit', 'contact_address') IS NOT NULL
BEGIN
   ALTER TABLE source_counterparty_audit
   ALTER COLUMN contact_address VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('source_counterparty_audit', 'contact_address2') IS NOT NULL
BEGIN
   ALTER TABLE source_counterparty_audit
   ALTER COLUMN contact_address2 VARCHAR(MAX)
    
END
GO
--------------

IF COL_LENGTH('counterparty_bank_info', 'Address1') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info
   ALTER COLUMN Address1 VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('counterparty_bank_info', 'Address2') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info
   ALTER COLUMN Address2 VARCHAR(MAX)
    
END
GO

IF COL_LENGTH('counterparty_bank_info_audit', 'Address1') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info_audit
   ALTER COLUMN Address1 VARCHAR(MAX)
    
END
GO
IF COL_LENGTH('counterparty_bank_info_audit', 'Address2') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info_audit
   ALTER COLUMN Address2 VARCHAR(MAX)
    
END
GO

IF COL_LENGTH('counterparty_bank_info', 'ACH_ABA') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info
   ALTER COLUMN ACH_ABA VARCHAR(50)
    
END
GO
IF COL_LENGTH('counterparty_bank_info', 'Account_no') IS NOT NULL
BEGIN
   ALTER TABLE counterparty_bank_info
   ALTER COLUMN Account_no VARCHAR(50)
    
END
GO