DELETE static_data_value where value_id=4505

set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description)
 values(4505,10007,'Monte Carlo Curve Source','Monte Carlo Curve Source')
set identity_insert static_data_value OFF


