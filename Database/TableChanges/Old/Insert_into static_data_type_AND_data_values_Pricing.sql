/*******************************************************
*  Created By :  Pawan KC                         
*  Created Date :20-Jan-2008
*******************************************************/

--select * from static_data_type where type_id = 1600

insert into static_data_type(type_id,type_name,internal,description)
values(1600,'Pricing',1,'Pricing') 

/* Static Data Values */

SET IDENTITY_INSERT static_data_value ON

INSERT INTO static_data_value([value_id],[type_id],[code],[description]) 
VALUES (1600,1600,'Average','Average')


SET IDENTITY_INSERT static_data_value OFF
