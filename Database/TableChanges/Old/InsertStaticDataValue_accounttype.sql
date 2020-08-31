insert into static_data_type(type_id,type_name,internal,description)
select 3000,'Account Type',1,'Account Type'
GO

set identity_insert static_data_value on
GO
insert into static_data_value(value_id,type_id,code,description)
select value_id,type_id,code,description from emissionstracker2_1.dbo.static_data_value where type_id=3000
GO
set identity_insert static_data_value off
GO
