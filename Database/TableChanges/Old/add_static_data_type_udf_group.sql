--Author: Tara Nath Subedi
--Issue Against: 3122
--Purpose: Adding 'UDF Group' static data type for UDF grouping concept in deal template tab.

IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=15600)
INSERT INTO static_data_type(type_id,type_name,internal,description) values ('15600','UDF Group','0','UDF Group')