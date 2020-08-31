/*
select * from state_properties_duration
*/
go
if NOT exists(select * from sys.columns where [object_id] = object_id('state_properties_duration') and [name] = 'cert_entity')
	alter table state_properties_duration ADD cert_entity INT



