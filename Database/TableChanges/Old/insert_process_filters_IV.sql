
/*
Author : Vishwas Khanal
Dated  : 03.15.2010
Desc   : i. Type ID inserted for the import of Activity Data and Allowance Data.
		 ii.Filter ID inserted for the import of Activity Data and Allowance Data.
Project: Emission Demo
*/
IF EXISTS (SELECT 'X' FROM static_data_type WHERE type_id = 13301)
DELETE FROM static_data_type WHERE type_id = 13301

IF EXISTS (SELECT 'X' FROM process_filters WHERE filterId = 'EMSImport')
DELETE FROM process_filters WHERE filterId = 'EMSImport'

IF NOT EXISTS (SELECT 'X' FROM static_data_type WHERE type_id = 13400)
INSERT INTO static_data_type (type_id,type_name,internal,description) SELECT 13400,'Activity Data',1,'Activity Data for Emission Import '

IF NOT EXISTS (SELECT 'X' FROM static_data_type WHERE type_id = 13500)
INSERT INTO static_data_type (type_id,type_name,internal,description) SELECT 13500,'Allowance Data',1,'Allowance Data for Emission Import'

IF NOT EXISTS (SELECT 'x' FROM process_filters WHERE filterId = 'ActivityImport')
INSERT INTO process_filters 
SELECT 'ActivityImport','static_data_type','type_name','type_id',100,'n',null,null union all
SELECT 'AllowanceImport','static_data_type','type_name','type_id',110,'n',null,null 
