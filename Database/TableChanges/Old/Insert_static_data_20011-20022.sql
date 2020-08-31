--select * from static_data_value where type_id=20000 order by value_Id
--delete from static_data_value where  type_id=20000 and value_id>=20012

set identity_insert static_data_value on

IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20012)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20012,20000,'Week +0: Working day','Week +0: Working day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20013)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20013,20000,'Week +0: Calendar day','Week +0: Calendar day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20014)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20014,20000,'Week +1: Working day','Week +1: Working day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20015)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20015,20000,'Week +1: Calendar day','Week +1: Calendar day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20016)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20016,20000,'Week +2: Working day','Week +2: Working day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20017)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20017,20000,'Week +2: Calendar day','Week +2: Calendar day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20018)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20018,20000,'Day +: Working day','Day +: Working day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20019)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20019,20000,'Day +: Calendar day','Day +: Calendar day')
END

IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20020)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20020,20000,'Day +: Calendar day - Prev Business Day','Day +: Calendar day - Prev Business Day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20021)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20021,20000,'Month +1: Calendar day - Prev Business Day','Month +1: Calendar day - Prev Business Day')
END
IF NOT EXISTS (SELECT 1 FROM static_data_value  WHERE value_id=20022)
BEGIN
	INSERT INTO static_data_value (value_id,type_id,code,description)
	VALUES (20022,20000,'Week +1: Calendar day - Prev Business Day','Week +1: Calendar day - Prev Business Day')
END
set identity_insert static_data_value off

