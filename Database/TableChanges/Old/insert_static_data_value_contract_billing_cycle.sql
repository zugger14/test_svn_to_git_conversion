DELETE FROM static_data_value where type_id=976
DELETE FROM static_data_type where type_id=976
--select * from static_data_type where internal=1 order by type_id


IF not exists(select * from static_data_type where type_Id=17900)
BEGIN

	INSERT INTO static_data_type(type_id,type_name,internal,description)
	SELECT 17900,'Contract Billing Cycle',1,'Contract Billing Cycle'


	SET identity_insert static_data_value ON
	INSERT INTO static_data_value(type_id,value_id,code,description)
	SELECT 17900,17900,'Bill By Calendar Month','Bill By Calendar Month'
	UNION
	SELECT 17900,17901,'User Defined','User Defined'

	
END