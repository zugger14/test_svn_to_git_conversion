IF COL_LENGTH('source_deal_header_template', 'header_buy_sell_flag') IS NULL AND COL_LENGTH('source_deal_header_template', 'buy_sell_flag') IS NOT NULL
	EXEC sp_RENAME 'source_deal_header_template.[buy_sell_flag]' , 'header_buy_sell_flag', 'COLUMN'

IF COL_LENGTH('source_deal_header_template', 'source_deal_header_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD source_deal_header_id INT
	PRINT 'Column source_deal_header_template.source_deal_header_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.source_deal_header_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'source_system_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD source_system_id INT
	PRINT 'Column source_deal_header_template.source_system_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.source_system_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'deal_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD deal_id VARCHAR(50)
	PRINT 'Column source_deal_header_template.deal_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.deal_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'deal_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD deal_date DATETIME
	PRINT 'Column source_deal_header_template.deal_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.deal_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'ext_deal_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD ext_deal_id VARCHAR(50)
	PRINT 'Column source_deal_header_template.ext_deal_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.ext_deal_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'structured_deal_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD structured_deal_id VARCHAR(50)
	PRINT 'Column source_deal_header_template.structured_deal_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.structured_deal_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'entire_term_start') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD entire_term_start DATETIME
	PRINT 'Column source_deal_header_template.entire_term_start added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.entire_term_start already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'entire_term_end') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD entire_term_end DATETIME
	PRINT 'Column source_deal_header_template.entire_term_end added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.entire_term_end already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'option_excercise_type') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD option_excercise_type CHAR
	PRINT 'Column source_deal_header_template.option_excercise_type added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.option_excercise_type already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'broker_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD broker_id INT
	PRINT 'Column source_deal_header_template.broker_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.broker_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'generator_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD generator_id INT
	PRINT 'Column source_deal_header_template.generator_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.generator_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'status_value_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD status_value_id INT
	PRINT 'Column source_deal_header_template.status_value_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.status_value_id already exists.'
END
GO



IF COL_LENGTH('source_deal_header_template', 'status_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD status_date DATETIME
	PRINT 'Column source_deal_header_template.status_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.status_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'assignment_type_value_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD assignment_type_value_id INT
	PRINT 'Column source_deal_header_template.assignment_type_value_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.assignment_type_value_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'compliance_year') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD compliance_year INT
	PRINT 'Column source_deal_header_template.compliance_year added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.compliance_year already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'state_value_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD state_value_id INT
	PRINT 'Column source_deal_header_template.state_value_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.state_value_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'assigned_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD assigned_date DATETIME
	PRINT 'Column source_deal_header_template.assigned_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.assigned_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'assigned_by') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD assigned_by VARCHAR(50)
	PRINT 'Column source_deal_header_template.assigned_by added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.assigned_by already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'generation_source') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD generation_source VARCHAR(250)
	PRINT 'Column source_deal_header_template.generation_source added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.generation_source already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'aggregate_environment') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD aggregate_environment VARCHAR(1)
	PRINT 'Column source_deal_header_template.aggregate_environment added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.aggregate_environment already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'aggregate_envrionment_comment') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD aggregate_envrionment_comment VARCHAR(250)
	PRINT 'Column source_deal_header_template.aggregate_envrionment_comment added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.aggregate_envrionment_comment already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'rec_price') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD rec_price FLOAT(53)
	PRINT 'Column source_deal_header_template.rec_price added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.rec_price already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'rec_formula_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD rec_formula_id INT
	PRINT 'Column source_deal_header_template.rec_formula_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.rec_formula_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'rolling_avg') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD rolling_avg CHAR
	PRINT 'Column source_deal_header_template.rolling_avg added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.rolling_avg already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'reference') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD reference VARCHAR(250)
	PRINT 'Column source_deal_header_template.reference added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.reference already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'deal_locked') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD deal_locked CHAR
	PRINT 'Column source_deal_header_template.deal_locked added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.deal_locked already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'close_reference_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD close_reference_id INT
	PRINT 'Column source_deal_header_template.close_reference_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.close_reference_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'deal_reference_type_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD deal_reference_type_id INT
	PRINT 'Column source_deal_header_template.deal_reference_type_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.deal_reference_type_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'unit_fixed_flag') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD unit_fixed_flag CHAR
	PRINT 'Column source_deal_header_template.unit_fixed_flag added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.unit_fixed_flag already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'broker_unit_fees') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD broker_unit_fees FLOAT(53)
	PRINT 'Column source_deal_header_template.broker_unit_fees added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.broker_unit_fees already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'broker_fixed_cost') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD broker_fixed_cost FLOAT(53)
	PRINT 'Column source_deal_header_template.broker_fixed_cost added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.broker_fixed_cost already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'broker_currency_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD broker_currency_id INT
	PRINT 'Column source_deal_header_template.broker_currency_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.broker_currency_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'term_frequency') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD term_frequency CHAR
	PRINT 'Column source_deal_header_template.term_frequency added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.term_frequency already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'option_settlement_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD option_settlement_date DATETIME
	PRINT 'Column source_deal_header_template.option_settlement_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.option_settlement_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'verified_by') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD verified_by VARCHAR(50)
	PRINT 'Column source_deal_header_template.verified_by added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.verified_by already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'verified_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD verified_date DATETIME	
	PRINT 'Column source_deal_header_template.verified_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.verified_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'risk_sign_off_by') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD risk_sign_off_by VARCHAR(50)	
	PRINT 'Column source_deal_header_template.risk_sign_off_by added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.risk_sign_off_by already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'risk_sign_off_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD risk_sign_off_date DATETIME
	PRINT 'Column source_deal_header_template.risk_sign_off_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.risk_sign_off_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'back_office_sign_off_by') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD back_office_sign_off_by VARCHAR(50)
	PRINT 'Column source_deal_header_template.back_office_sign_off_by added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.back_office_sign_off_by already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'back_office_sign_off_date') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD back_office_sign_off_date DATETIME
	PRINT 'Column source_deal_header_template.back_office_sign_off_date added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.back_office_sign_off_date already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'book_transfer_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD book_transfer_id INT
	PRINT 'Column source_deal_header_template.book_transfer_id added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.book_transfer_id already exists.'
END
GO

IF COL_LENGTH('source_deal_header_template', 'confirm_status_type') IS NULL
BEGIN
	ALTER TABLE source_deal_header_template ADD confirm_status_type INT
	PRINT 'Column source_deal_header_template.confirm_status_type added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_header_template.confirm_status_type already exists.'
END
GO