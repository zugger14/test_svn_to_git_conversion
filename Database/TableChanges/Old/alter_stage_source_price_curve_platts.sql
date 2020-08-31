/*
Author : Vishwas Khanal
Dated  : Nov.04.2009
*/
alter table stage_source_price_curve_platts alter column [index] varchar(100)
go
if exists(select * from sys.columns where [object_id] = object_id('stage_source_price_curve_platts') and [name] = 'maturitydate')
alter table stage_source_price_curve_platts drop column maturitydate



