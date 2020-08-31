
if object_id('forward_value_report') is not null
drop table dbo.forward_value_report
go


create table dbo.forward_value_report(
	Rowid int identity(1,1),as_of_date date,[book_id] int,[counterparty_id] int,[user_toublock_id] int,[toublock_id] int
	,[country_id] int,commodity_id int,
	logical_code varchar(11),[yr] int,[seasonal] date,[qtr] tinyint,[term_start] date,
	position numeric(26,10), forward_value float,  avg_base_curve_value float,  avg_curve_value float
	,conv_func_cur_value float,conv_base_UOM_value float,func_currency_id int,base_UOM_id float
)
