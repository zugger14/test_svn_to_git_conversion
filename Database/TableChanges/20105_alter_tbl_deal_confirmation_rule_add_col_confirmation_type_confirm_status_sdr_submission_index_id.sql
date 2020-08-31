IF COL_LENGTH('deal_confirmation_rule', 'confirmation_type') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD confirmation_type INT
END
GO

IF COL_LENGTH('deal_confirmation_rule', 'legal_entity') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD legal_entity INT
END
GO
 
IF COL_LENGTH('deal_confirmation_rule', 'book') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD book INT
END
GO	

IF COL_LENGTH('deal_confirmation_rule', 'counterparty2') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD counterparty2 INT
END
GO	
	
IF COL_LENGTH('deal_confirmation_rule', 'deal_sub_type') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD deal_sub_type INT
END
GO
		
IF COL_LENGTH('deal_confirmation_rule', 'deal_group') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD deal_group INT
END
GO		
		
IF COL_LENGTH('deal_confirmation_rule', 'location_group') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD location_group INT
END
GO	
	
IF COL_LENGTH('deal_confirmation_rule', 'location') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD location INT
END
GO	
	
IF COL_LENGTH('deal_confirmation_rule', 'index_group') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD index_group INT
END
GO		
IF COL_LENGTH('deal_confirmation_rule', 'index_id') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD index_id INT
END
GO		

IF COL_LENGTH('deal_confirmation_rule', 'deal_status') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD deal_status INT
END
GO		

IF COL_LENGTH('deal_confirmation_rule', 'sdr_submission') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD sdr_submission CHAR(1)
END
GO	
	
IF COL_LENGTH('deal_confirmation_rule', 'confirm_status') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD confirm_status INT
END
GO	
	
IF COL_LENGTH('deal_confirmation_rule', 'platform') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD [platform] INT
END
GO		
		
	
	
	
	
	
	
