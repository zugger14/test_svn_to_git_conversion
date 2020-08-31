if not exists(select 'x' from static_data_type where type_id=17500)
BEGIN
Insert into static_data_type(type_id,type_name,internal,description)
select 17500,'Forecast Profile Type',1,'Forecast Profile Type'


set identity_insert static_data_value ON

insert into static_data_value(value_id,type_id,code,description) values(17500,17500,'Forecast','Forecast')
insert into static_data_value(value_id,type_id,code,description) values(17501,17500,'Profile','Profile')
insert into static_data_value(value_id,type_id,code,description) values(17502,17500,'National Profile','National Profile')
insert into static_data_value(value_id,type_id,code,description) values(17503,17500,'Essent Profile','Essent Profile')

set identity_insert static_data_value OFF

END