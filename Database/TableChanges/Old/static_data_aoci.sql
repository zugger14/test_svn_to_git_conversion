set identity_insert static_data_value on
if not exists(select * from static_data_value where value_id=524)
insert into static_data_value(value_id,type_id,code,description)
select 524,520,'AOCI release by lagging month','AOCI release by lagging month'
set identity_insert static_data_value off
