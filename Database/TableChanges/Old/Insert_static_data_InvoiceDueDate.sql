SET identity_insert static_data_value on
GO
Insert into static_data_value(value_id,type_id,code,description)
select 970,977,'7 Days or first business day after','7 Days or first business day after'
GO
SET identity_insert static_data_value off
GO
