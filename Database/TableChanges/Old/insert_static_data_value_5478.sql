SET identity_insert static_data_value  ON

IF NOT EXISTS(SELECT 'X' FROM static_data_value where value_id = 5478)
BEGIN 
	INSERT INTO static_data_value(value_id, [type_id], code, [description])
	SELECT 5478, 5450, 'NCRETS', 'NCRETS'
	print 'static data value 5478 inserted'
END
ELSE
BEGIN
	print 'static data value 5478 already exists'
END

SET  identity_insert static_data_value  OFF