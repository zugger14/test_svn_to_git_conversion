--delete from user_defined_deal_fields
--select * from static_data_value where type_id=5500 order by value_id


--delete from user_defined_deal_fields_template --where field_name like '55%'
--delete from transportation_rate_schedule 
--delete from static_data_value where type_id=5500
--delete from static_data_type where type_id=5500
--insert into static_data_type(type_id,type_name,internal,description) values(5500,'User Defined Fields',0,'User Defined Fields')

set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(5516,5500,'Deliver_Counterparty','Deliver Counterparty')
insert into static_data_value(value_id,type_id,code,description) values(5517,5500,'Recieve_Counterparty','Recieve Counterparty')
set identity_insert static_data_value off

--insert into transportation_rate_schedule (rate_schedule_id,rate_type_id,rate)
--select 1,value_id,null from static_data_value where type_id=5500

update transportation_rate_schedule set rate_schedule_id=1800 where rate_schedule_id=1
update transportation_rate_schedule set rate_schedule_id=1801 where rate_schedule_id=2








