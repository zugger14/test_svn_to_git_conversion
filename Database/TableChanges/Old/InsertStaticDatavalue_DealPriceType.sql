insert into static_data_type(type_id,type_name,internal,description)
	select 5650,'Deal Price Type',1,'Deal Price Type'


SET identity_insert static_data_value ON
GO
	insert into static_data_value(value_id,type_id,code,description)
		select 5650,5650,'Original Deal Price','Original Deal Price'
	insert into static_data_value(value_id,type_id,code,description)
		select 5651,5650,'Market Price','Market Price'
	insert into static_data_value(value_id,type_id,code,description)
		select 5652,5650,'Formula Based Price','Formula Based Price'
Go
SET identity_insert static_data_value OFF
GO