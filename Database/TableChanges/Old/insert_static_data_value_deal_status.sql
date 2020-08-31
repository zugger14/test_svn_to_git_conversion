INSERT INTO static_data_type(type_id,type_name,internal,description)
select 5600,'Deal Status',1,'Deal Status'
GO

SET identity_insert static_data_value on
GO
INSERT INTO static_data_value(value_id,type_id,code,description)
select 5600,5600,'In progress','In progress'
GO
INSERT INTO static_data_value(value_id,type_id,code,description)
select 5601,5600,'Complete','Complete'
GO
INSERT INTO static_data_value(value_id,type_id,code,description)
select 5602,5600,'Executed','Executed'
GO
SET identity_insert static_data_value on
GO