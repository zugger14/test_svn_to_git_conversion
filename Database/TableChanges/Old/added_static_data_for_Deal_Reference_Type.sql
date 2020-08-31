alter table source_Deal_header add deal_reference_type_id int

go

insert into static_data_type(type_id,type_name,internal,description) values(12500,'Deal Reference Type',1,'Deal Reference Type')

set identity_insert static_data_value on

insert into static_data_value(value_id,type_id,code,description) values(12500,12500,'Offset','Offset')
insert into static_data_value(value_id,type_id,code,description) values(12501,12500,'Storage','Storage')
insert into static_data_value(value_id,type_id,code,description) values(12502,12500,'Rollover','Rollover')
insert into static_data_value(value_id,type_id,code,description) values(12503,12500,'Transfer','Transfer')
insert into static_data_value(value_id,type_id,code,description) values(12504,12500,'Transportation','Transportation')
insert into static_data_value(value_id,type_id,code,description) values(12505,12500,'EFP_Trigger','EFP_Trigger')
insert into static_data_value(value_id,type_id,code,description) values(12506,12500,'Options','Options')
insert into static_data_value(value_id,type_id,code,description) values(12507,12500,'Copy','Copy')
insert into static_data_value(value_id,type_id,code,description) values(12508,12500,'Close','Close')

set identity_insert static_data_value off
