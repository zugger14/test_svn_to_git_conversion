/*
Insert time zone value in the adiha default table
select * from time_zones
select * from adiha_default_codes
select * from adiha_default_codes_params
select * from adiha_default_codes_values
select * from adiha_default_codes_values_possible

delete from adiha_default_codes_params where default_code_id=27
*/


if not exists(select * from adiha_default_codes where default_code_id=31)
BEGIN
	INSERT INTO adiha_default_codes(default_code_id,default_code,code_description,code_def,instances)
	SELECT 31,'default_time_zone','Define System Time Zone','System Time Zone',1


	INSERT INTO adiha_default_codes_params(seq_no,default_code_id,var_name,type_id,value_type)
	SELECT 1,31,'default_time_zone',3,'h'

	INSERT INTO adiha_default_codes_values(instance_no,default_code_id,seq_no,var_value,description)
	SELECT 1,31,1,6,NULL
END
