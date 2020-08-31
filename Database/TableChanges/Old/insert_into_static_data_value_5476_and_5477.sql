
IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 5476)
BEGIN
	SET IDENTITY_INSERT static_data_value ON 
	INSERT INTO static_data_value(value_id, type_id, code, description) VALUES (5476, 5450, 'RECs Actual (CSV)', 'RECs Actual (CSV)')
	SET IDENTITY_INSERT static_data_value OFF
END

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 5477)
BEGIN
	SET IDENTITY_INSERT static_data_value ON 
	INSERT INTO static_data_value(value_id, type_id, code, description) VALUES (5477, 5450, 'NCRETS Retirement (CSV)', 'NCRETS Retirement (CSV)')
	SET IDENTITY_INSERT static_data_value OFF
END
