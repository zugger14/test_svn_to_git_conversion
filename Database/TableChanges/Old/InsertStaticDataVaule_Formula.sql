/*
select * from static_data_value where type_id=800 order by value_id
DELETE FROM static_data_value where value_id in(887,888,889)
*/
set identity_insert static_data_value on
GO
insert into static_data_value(value_id,type_id,code,description)
select 887,800,'24HrsAvg','24 hr Continuous Rolling Average of CEMS Data'
UNION
select 888,800,'6MinsBlockAvg','Six Minute Block Avg'
UNION
select 889,800,'3Hrs2Samples','Arithmetic Average of three 2 hr samples'
GO
set identity_insert static_data_value off
GO

if not exists(select * from edr_xml_file_map_detail)
BEGIN
	insert into edr_xml_file_map_detail(record_type_code,record_sub_type_code,record_data,record_description,isHourly,isDerived)
	select 300,1605,NULL,'Op Time',1,NULL
	UNION
	SELECT 300,1607,NULL,'Gross Load',1,NULL
	UNION
	SELECT 300,1603,'HI','Heat Input',NULL,1
	UNION
	SELECT 330,1600,'CO2','CO2 mass emission rate for the hour',NULL,1
	UNION
	SELECT 320,1609,'NOXR','Adjusted average NOx emission rate for the hour',NULL,1
	UNION
	SELECT 324,1613,'NOX','Nox mass emission rate for the hour for fuel',NULL,1
	UNION
	SELECT 310,1600,'SO2','SO2 mass emission rate for the hour',NULL,1

END
GO