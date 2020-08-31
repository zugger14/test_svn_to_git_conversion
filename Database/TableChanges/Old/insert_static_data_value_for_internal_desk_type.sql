
delete static_data_value where  type_id=17300

set identity_insert static_data_value ON
insert into static_data_value(value_id,type_id,code,description) values(17300,17300,'Deal Volume','Deal Volume')
insert into static_data_value(value_id,type_id,code,description) values(17301,17300,'Forecasted','Forecasted')
insert into static_data_value(value_id,type_id,code,description) values(17302,17300,'Shaped','Shaped')
set identity_insert static_data_value OFF
