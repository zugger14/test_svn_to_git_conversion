
if exists (select * from static_data_value where type_id=10102 )delete from static_data_value where type_id =10102
if exists (select * from static_data_value where type_id=10103 )delete from static_data_value where type_id =10103
if exists (select * from static_data_value where type_id=10104 )delete from static_data_value where type_id =10104
if exists (select * from static_data_value where type_id=10105 )delete from static_data_value where type_id =10105
/*Insert static data values*/
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1520,'Variance/Covariance Approach','Variance/Covariance Approach',NULL,NULL,NULL,NULL) 
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1520,'Historical Simulation','Historical Simulation',NULL,NULL,NULL,NULL) 
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1520,'Monte Carlo Simulation','Monte Carlo Simulation',NULL,NULL,NULL,NULL) 

insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1560,'Daily Prices','Daily Prices',NULL,NULL,NULL,NULL)
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1560,'Daily Return','Daily Return',NULL,NULL,NULL,NULL)
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1560,'Arithmetic Rate of Return','Arithmetic Rate of Return',NULL,NULL,NULL,NULL)
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1560,'Geometric Rate of Return','Geometric Rate of Return',NULL,NULL,NULL,NULL)

insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1500,' 1.65','95%',NULL,NULL,NULL,NULL)
insert static_data_value ( type_id,code,description,entity_id,xref_value_id,xref_value,category_id)
values ( 1500,'2.33','99%',NULL,NULL,NULL,NULL)