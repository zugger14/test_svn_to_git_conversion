IF COL_LENGTH('contract_group_detail', 'Invoice_group') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD Invoice_group VARCHAR(200)
END
GO

IF COL_LENGTH('contract_group_detail', 'invoice_template_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD invoice_template_id  INT
END
GO

IF COL_LENGTH('contract_group_detail', 'buy_sell_flag') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD buy_sell_flag CHAR(1)
END
GO

IF COL_LENGTH('contract_group_detail', 'location_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD location_id INT
END
GO

IF COL_LENGTH('contract_group_detail', 'true_up_charge_type_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_charge_type_id INT
END
GO


IF COL_LENGTH('contract_group_detail', 'true_up_no_month') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_no_month INT
END
GO

IF COL_LENGTH('contract_group_detail', 'true_up_applies_to') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_applies_to CHAR(1)
END
GO

IF COL_LENGTH('contract_group_detail', 'is_true_up') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD is_true_up CHAR(1)
END
GO





