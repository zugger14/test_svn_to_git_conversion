insert into static_data_type(type_id,type_name,internal,description) values(1650,'Delivery Status',1,'Delivery Status')




set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(1650,1650,'Deliverered','Deliverered')
insert into static_data_value(value_id,type_id,code,description) values(1651,1650,'In transit','In transit')
insert into static_data_value(value_id,type_id,code,description) values(1652,1650,'Hold','Hold')
insert into static_data_value(value_id,type_id,code,description) values(1653,1650,'Cancelled','Cancelled')
set identity_insert static_data_value off