DELETE FROM static_data_value WHERE value_id = 5461
set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(5461,5450,'epa_allowance_data','Allowance Data Vectren')
set identity_insert static_data_value OFF

go

DELETE FROM static_data_value WHERE value_id = 2203
set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(2203,2200,'Legacy ID','Legacy ID')
set identity_insert static_data_value OFF