insert into source_system_description(source_system_name,connection_param1,connection_param2,connection_param3,system_name_value_id)
values('NYMEX','self','db','db',600)


insert into source_system_description(source_system_name,connection_param1,connection_param2,connection_param3,system_name_value_id)
values('Treasury','self','db','db',600)

insert into external_source_import(source_system_id,data_type_id) values(13,4008)
insert into external_source_import(source_system_id,data_type_id) values(14,4008)