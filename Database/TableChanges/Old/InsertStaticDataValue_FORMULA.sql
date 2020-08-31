/*
select * from static_data_value where type_id=800 order by value_id


*/
SET identity_insert static_data_value ON
GO
	insert into static_data_value(value_id,type_id,code,description)
	select 886,800,'RelativePeriod','Gives the relative period between As Of Date and Maturity Date'
Go
SET identity_insert static_data_value ON
GO
