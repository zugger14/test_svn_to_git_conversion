/*************************************8
insert in static data compliance data
select * from static_data_value where type_id=10088 order by value_id
select * from static_data_value where type_id=10090 order by value_id
select * from static_data_value where type_id=10089 order by value_id

select * from static_data_value where code='Administrative Order'

*******************************/
set identity_insert static_data_value on
GO
If not exists(select * from static_data_value where value_id=5444)
INSERT INTO static_data_value(value_id,type_id,code,[description])
SELECT 5444,10088,'Contract Administration','Contract Administration'
GO
set identity_insert static_data_value off
GO


Update static_data_value set code='General' where value_id=5401
Update static_data_value set code='Contract Approval',description='Contract Approval' where value_id=5411



