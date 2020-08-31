/*
select * from static_data_type

*/
IF NOT EXISTS(select * from static_data_type WHERE type_id=15001)
	insert into static_data_type(type_id,type_name,internal,description)
	select 15001,'Block Type Group',0,'Block Type Group'
GO
