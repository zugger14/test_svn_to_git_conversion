
insert into static_data_type(type_id,type_name,internal,description)
select 17300,'Deal Profile',0,'Deal Profile'

set identity_insert static_data_value ON
insert into static_data_value(type_id,value_id,code,description)
select 17300,-6,'Fixed','Fixed'
UNION
select 17300,-7,'Forecasted','Forecasted'
set identity_insert static_data_value OFF
