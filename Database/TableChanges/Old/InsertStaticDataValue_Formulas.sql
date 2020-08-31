/****************
Insert into static_data_value for Formula
****************/
set  identity_insert static_data_value on
go
insert into static_data_value(value_id,type_id,code,description)
select 873,800,'Isdbo.FNAIsHoliDay()','Isdbo.FNAIsHoliDay()'
UNION
select 874,800,'dbo.FNAWeekDay()','dbo.FNAWeekDay()'
GO
set  identity_insert static_data_value off
go

update formula_editor set formula=replace(formula,'UDFCharges','UDFValue')
GO
update static_data_value set code='UDFValue' Where value_id=861
	
