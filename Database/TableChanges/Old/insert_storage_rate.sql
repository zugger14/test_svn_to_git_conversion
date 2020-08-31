set identity_insert static_data_value on

insert into static_data_value(value_id,type_id,code,description) values(5510,5500,'injection_fees','Injection Fees')
insert into static_data_value(value_id,type_id,code,description) values(5511,5500,'withdrawal_fees','Withdrawal Fees')
insert into static_data_value(value_id,type_id,code,description) values(5512,5500,'cost_of_carry_fees','Cost of Carry Fees')
insert into static_data_value(value_id,type_id,code,description) values(5513,5500,'injection_fuel_cost_in_%','Injection Fuel Cost in %')
insert into static_data_value(value_id,type_id,code,description) values(5514,5500,'withdrawal_fuel_cost_in_%','Withdrawal Fuel Cost in %')

set identity_insert static_data_value off



insert into transportation_rate_schedule (rate_schedule_id,rate_type_id,rate)
select 2,value_id,null from static_data_value where value_id between 5510 and 5514

update transportation_rate_schedule set rate=100 where rate_type_id=5510
update transportation_rate_schedule set rate=200 where rate_type_id=5511
update transportation_rate_schedule set rate=.2 where rate_type_id=5512
update transportation_rate_schedule set rate=300 where rate_type_id=5513
update transportation_rate_schedule set rate=400 where rate_type_id=5514






