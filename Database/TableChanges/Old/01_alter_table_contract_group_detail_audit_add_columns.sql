IF COL_LENGTH('contract_group_detail_audit', 'radio_automatic_manual') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD radio_automatic_manual char
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'contract_template') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD contract_template int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'contract_component_template') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD contract_component_template int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'effective_date') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD effective_date datetime
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'invoice_template_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD invoice_template_id int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD settlement_date datetime
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD settlement_calendar int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'group1') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD group1 int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'group2') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD group2 int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'group3') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD group3 INT
END 
GO

IF COL_LENGTH('contract_group_detail_audit', 'group4') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD group4 int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'leg') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD leg int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'location_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD location_id int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'true_up_applies_to') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD true_up_applies_to char
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'true_up_no_month') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD true_up_no_month int
END
GO


IF COL_LENGTH('contract_group_detail_audit', 'is_true_up') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD is_true_up char
END
GO


IF COL_LENGTH('contract_group_detail_audit', 'true_up_charge_type_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD true_up_charge_type_id int
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'buy_sell_flag') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD buy_sell_flag char
END
GO

IF COL_LENGTH('contract_group_detail_audit', 'default_gl_code_cash_applied') IS NULL
BEGIN
    ALTER TABLE contract_group_detail_audit ADD default_gl_code_cash_applied int
END
GO