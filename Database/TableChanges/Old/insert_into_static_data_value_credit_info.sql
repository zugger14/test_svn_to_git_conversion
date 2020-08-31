IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = '1+' AND [type_id] = 10098) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(10098, '1+', '1+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'a+' AND [type_id] = 10098) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(10098, 'a+', 'a+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A' AND [type_id] = 11099) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11099, 'A', 'A')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A+' AND [type_id] = 11099) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11099, 'A+', 'A+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'B+' AND [type_id] = 11099) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11099, 'B+', 'B+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A' AND [type_id] = 11100) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11100, 'A', 'A')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A+' AND [type_id] = 11100) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11100, 'A+', 'A+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'B+' AND [type_id] = 11100) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11100, 'B+', 'B+')
END


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A' AND [type_id] = 11101) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11101, 'A', 'A')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A+' AND [type_id] = 11101) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11101, 'A+', 'A+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'B+' AND [type_id] = 11101) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11101, 'B+', 'B+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A' AND [type_id] = 11102) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11102, 'A', 'A')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'A+' AND [type_id] = 11102) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11102, 'A+', 'A+')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'B+' AND [type_id] = 11102) 
BEGIN
	INSERT INTO static_data_value([type_id],code, [description])
	VALUES(11102, 'B+', 'B+')
END