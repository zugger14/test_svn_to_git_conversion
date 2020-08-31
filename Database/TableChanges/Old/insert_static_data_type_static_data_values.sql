/*******************************************************
*  Created By :  Mukesh Singh                           
*  Created Date :26-Dec-2008
*  Purpose : To Insert Time Zone in Static data Type 
*	and Static Data values for the time Zones
*
*
*******************************************************/

--select * from static_data_type where type_id = 1400
--select * from static_data_value where type_id = 1400

insert into static_data_type(type_id,type_name,internal,description)
values(1400,'Time Zone',1,'Time Zone') 

/* Static Data Values */

SET IDENTITY_INSERT static_data_value ON

INSERT INTO static_data_value([value_id],[type_id],[code],[description]) 
VALUES (1400,1400,'ES','Eastern Standard')

INSERT INTO static_data_value([value_id],[type_id],[code],[description]) 
VALUES (1401,1400,'MS','Mountain Standard')

INSERT INTO static_data_value([value_id],[type_id],[code],[description]) 
VALUES (1402,1400,'PS','Pacific Standard')

INSERT INTO static_data_value([value_id],[type_id],[code],[description]) 
VALUES (1403,1400,'CS','Central Standard')

SET IDENTITY_INSERT static_data_value OFF


