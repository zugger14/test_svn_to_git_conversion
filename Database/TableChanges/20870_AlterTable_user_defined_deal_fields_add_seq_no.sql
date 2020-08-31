IF COL_LENGTH('user_defined_deal_fields', 'seq_no') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD seq_no INT
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'seq_no') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD seq_no INT
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'seq_no') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD seq_no INT
END
GO