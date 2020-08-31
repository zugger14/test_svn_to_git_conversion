-- Column true_up_charge_type_id
IF COL_LENGTH('contract_group_detail', 'true_up_charge_type_id') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_charge_type_id INT
END
ELSE
BEGIN
    PRINT 'true_up_charge_type_id Already Exists.'
END 
GO
-- Column true_up_no_month	
IF COL_LENGTH('contract_group_detail', 'true_up_no_month') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_no_month INT
END
ELSE
BEGIN
    PRINT 'true_up_no_month Already Exists.'
END 
GO
-- Column true_up_applies_to	
IF COL_LENGTH('contract_group_detail', 'true_up_applies_to') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD true_up_applies_to CHAR(1)
END
ELSE
BEGIN
    PRINT 'true_up_applies_to Already Exists.'
END 
GO	
-- Column is_true_up
IF COL_LENGTH('contract_group_detail', 'is_true_up') IS NULL
BEGIN
    ALTER TABLE contract_group_detail ADD is_true_up CHAR(1)
END
ELSE
BEGIN
    PRINT 'is_true_up Already Exists.'
END 
GO	
