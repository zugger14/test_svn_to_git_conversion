/*
select * from static_data_type where type_id=2300
select * from static_data_value where type_id=2300
*/
INSERT INTO static_data_type(type_id,type_name,internal,description)
select 2300,'Inventory Calc Type',1,'Inventory Calc Type'
GO
SET identity_insert static_data_value on
GO
INSERT INTO static_data_value(value_id,type_id,code,description)
select 2300,2300,'WACOG','Weighted Average Cost of Goods'
GO
SET identity_insert static_data_value on
GO