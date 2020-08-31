IF COL_LENGTH('user_defined_deal_fields', 'currency_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD currency_id INT REFERENCES source_currency(source_currency_id);
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'currency_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD currency_id INT
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'currency_id') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD currency_id INT
END
GO

IF COL_LENGTH('user_defined_deal_fields', 'uom_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD uom_id INT REFERENCES source_uom(source_uom_id);
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'uom_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD uom_id INT
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'uom_id') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD uom_id INT
END
GO

IF COL_LENGTH('user_defined_deal_fields', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ADD counterparty_id INT REFERENCES source_counterparty(source_counterparty_id);
END
GO

IF COL_LENGTH('user_defined_deal_fields_audit', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD counterparty_id INT REFERENCES source_counterparty(source_counterparty_id);
END
GO

IF COL_LENGTH('delete_user_defined_deal_fields', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD counterparty_id INT REFERENCES source_counterparty(source_counterparty_id);
END
GO
