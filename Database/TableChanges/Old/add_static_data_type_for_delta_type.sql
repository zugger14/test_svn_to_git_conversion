
IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=17400)
begin
	INSERT INTO static_data_type(type_id,type_name,internal,description) values ('17400','Delta Type','1','Delta Type')

	set identity_insert static_data_value on
	insert into static_data_value(value_id,type_id,code,description) values(17401,17400,'New Deal','New Deal')
	insert into static_data_value(value_id,type_id,code,description) values(17402,17400,'Deleted Deal','Deleted Deal')
	insert into static_data_value(value_id,type_id,code,description) values(17403,17400,'Forecast Volume Change','Forecast Volume Change')
	insert into static_data_value(value_id,type_id,code,description) values(17404,17400,'Deal Change','Deal Change')
	insert into static_data_value(value_id,type_id,code,description) values(17405,17400,'Volume delivered','Volume delivered')
	set identity_insert static_data_value OFF
	
	--ALTER TABLE source_minor_location add proxy_location_id int
END 