/*
select * from static_data_value where type_id=800 order by value_id

*/


set identity_insert static_data_value ON
GO
if not exists(select * from static_data_value where value_id in(870))
	insert into static_data_value(value_id,type_id,code,description)
	select 870,800,'LagCurve','Function to get the Lag curve value'

if not exists(select * from static_data_value where value_id in(871))
	insert into static_data_value(value_id,type_id,code,description)
	select 871,800,'PriorCurve','Function to get the Prior curve value'
	
if not exists(select * from static_data_value where value_id in(875))
	insert into static_data_value(value_id,type_id,code,description)
	select 875,800,'WACOG_Sale','Function to calculate weighted average cost of gas for the given daily as of date'
	
if not exists(select * from static_data_value where value_id in(876))
	insert into static_data_value(value_id,type_id,code,description)
	select 876,800,'WACOG_Buy','Function to calculate weighted average cost of gas for the given daily as of date'
GO
set identity_insert static_data_value OFF
GO

