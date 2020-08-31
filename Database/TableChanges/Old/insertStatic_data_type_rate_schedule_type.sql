delete from user_defined_deal_fields


delete from user_defined_deal_fields_template --where field_name like '55%'
delete from transportation_rate_schedule 
delete from static_data_value where type_id=5500
delete from static_data_type where type_id=5500
insert into static_data_type(type_id,type_name,internal,description) values(5500,'User Defined Fields',0,'User Defined Fields')

set identity_insert static_data_value on

insert into static_data_value(value_id,type_id,code,description) values(5500,5500,'MDQ','MDQ')
insert into static_data_value(value_id,type_id,code,description) values(5501,5500,'reservation_charge','Reservation Charge')
insert into static_data_value(value_id,type_id,code,description) values(5502,5500,'commodity','Commodity')
insert into static_data_value(value_id,type_id,code,description) values(5503,5500,'gas_research_institute_charge','Gas Research Institute Charge')
insert into static_data_value(value_id,type_id,code,description) values(5504,5500,'actual_cost_adj_charge','Actual Cost Adj Charge')
insert into static_data_value(value_id,type_id,code,description) values(5505,5500,'take_of_pay_charge','Take of Pay Charge')
insert into static_data_value(value_id,type_id,code,description) values(5506,5500,'other_charges','Other Charges')
insert into static_data_value(value_id,type_id,code,description) values(5507,5500,'fuel_charge','Fuel Charge')
insert into static_data_value(value_id,type_id,code,description) values(5508,5500,'currency','Currency')
insert into static_data_value(value_id,type_id,code,description) values(5509,5500,'UOM','UOM')

set identity_insert static_data_value off



insert into transportation_rate_schedule (rate_schedule_id,rate_type_id,rate)
select 1,value_id,null from static_data_value where type_id=5500

update transportation_rate_schedule set rate=100 where rate_type_id=5504
update transportation_rate_schedule set rate=200 where rate_type_id=5502
update transportation_rate_schedule set rate=.2 where rate_type_id=5507
update transportation_rate_schedule set rate=300 where rate_type_id=5503
update transportation_rate_schedule set rate=400 where rate_type_id=5506
update transportation_rate_schedule set rate=500 where rate_type_id=5501
update transportation_rate_schedule set rate=600 where rate_type_id=5505
update transportation_rate_schedule set rate=100 where rate_type_id=5500

delete transportation_rate_schedule where rate is null
alter table user_defined_deal_fields_template alter column field_name int







