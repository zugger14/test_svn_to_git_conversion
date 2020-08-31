
SET IDENTITY_INSERT dbo.static_data_value ON

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5149 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5149, 10013, 'Banked', 'Banked')
ELSE PRINT '5149 already exists'

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5180 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5180, 10013, 'Cap and Trade', 'Cap and Trade')
ELSE PRINT '5180 already exists'

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5146 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5146, 10013, 'RPS Compliance', 'RPS Compliance')
ELSE PRINT '5146 already exists'

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5173 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5173, 10013, 'Sold/Transfer', 'Sold/Transfer')
ELSE PRINT '5173 already exists'

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5148 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5148, 10013, 'Voluntary', 'Voluntary')
ELSE PRINT '5148 already exists'

IF NOT EXISTS (SELECT 'x' FROM dbo.static_data_value WHERE value_id = 5144 and type_id = 10013) 
INSERT INTO static_data_value(value_id, type_id, code, description) 
	VALUES (5144, 10013, 'WriteOff/Retire', 'WriteOff/Retire')
ELSE PRINT '5144 already exists'

SET IDENTITY_INSERT dbo.static_data_value OFF
