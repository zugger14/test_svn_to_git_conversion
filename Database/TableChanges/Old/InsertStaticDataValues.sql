/*******************************
Insert new static Data types
select * from static_data_type order by type_id

*******************************/
IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 13000)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 13000,'Technology Sub Type',1,'Technology Sub Type'


IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 13100)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 13100,'User Defined Group1',1,'User Defined Group1'

IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 13200)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 13200,'User Defined Group2',1,'User Defined Group2'

IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id = 13300)
	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 13300,'User Defined Group3',1,'User Defined Group3'
