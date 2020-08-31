IF COL_LENGTH('user_defined_deal_fields', 'contract_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD contract_id INT
END
GO

IF COL_LENGTH('user_defined_deal_fields', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD receive_pay CHAR(1)
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'contract_id') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD contract_id INT
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD receive_pay CHAR(1)
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'contract_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD contract_id INT
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD receive_pay CHAR(1)
END
GO

IF COL_LENGTH('user_defined_deal_detail_fields', 'contract_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD contract_id INT
END
GO

IF COL_LENGTH('user_defined_deal_detail_fields', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD receive_pay CHAR(1)
END
GO

IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'contract_id') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD contract_id INT
END
GO

IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD receive_pay CHAR(1)
END
GO

IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'contract_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD contract_id INT
END
GO

IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'receive_pay') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD receive_pay CHAR(1)
END
GO