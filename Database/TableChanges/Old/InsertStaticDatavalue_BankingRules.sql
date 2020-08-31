/*
select * from static_data_value where type_id=3500 order by value_id
select * from static_data_type where type_name like '%certi%'
*/

insert into static_data_type(type_id,type_name,internal,description)
select 3500,'Banking Rules',1,'Banking Rules defined accoring to certification system'


SET identity_insert static_data_value ON
GO
	insert into static_data_value(value_id,type_id,code,description)
	select 3500,3500,'Green-E','Green-E'
Go
SET identity_insert static_data_value OFF
GO