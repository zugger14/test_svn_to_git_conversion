set identity_insert static_data_value on
GO
if not exists(select * from static_data_value where value_id=894)
insert into static_data_value(value_id,type_id,code,description)
select 894,800,'AverageHourlyPrice','Find average hourly price for a given curve'
GO
set identity_insert static_data_value off
GO