/*****************************
Insert static_data_value for "Product Type" And Price type"
select * from static_data_value where type_id=1950
select * from static_data_value where type_id=1980
select * from static_data_type where type_id =10002
select * from static_data_type where type_id =10016
select * from static_data_type where type_name like '%tech%'
select * from static_data_type where type_name like '%fuel%'

select * from static_data_value where type_id=10009
select * from static_data_value where type_id=10023

*****************************/
IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 1950)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 1950,'Product Type',1,'Product Type'


GO
	SET identity_insert Static_data_value ON
GO
	IF NOT EXISTS (SELECT 'x' FROM static_data_value WHERE value_id = 1980)
	BEGIN
		INSERT INTO static_data_value(value_id,type_id,code,description)
		SELECT 1950,1950,'Energy','Energy'
		UNION
		SELECT 1951,1950,'Reserve','Reserve'
		UNION
		SELECT 1952,1950,'Admin Fees','Admin Fees'
	END

GO
	SET identity_insert Static_data_value OFF
GO

IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 10009)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 10009,'Technology Type',1,'Technology Type'

GO

IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 10023)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 10023,'Fuel Type',1,'Fuel Type'


GO

IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 1980)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 1980,'Price Type',1,'Price Type'


GO
	SET identity_insert Static_data_value ON
GO
	IF NOT EXISTS (SELECT 'x' FROM static_data_value WHERE value_id = 1980)
	BEGIN
		INSERT INTO static_data_value(value_id,type_id,code,description)
		SELECT 1980,1980,'Ex-Ante','Ex-Ante'
		UNION
		SELECT 1981,1980,'Ex-Post','Ex-Post'
	END

GO
	SET identity_insert Static_data_value OFF
